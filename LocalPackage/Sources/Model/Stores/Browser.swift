import DataSource
import Observation
import SwiftUI
import WebUI

@MainActor @Observable public final class Browser: Composable {
    private let appStateClient: AppStateClient
    private let uiApplicationClient: UIApplicationClient
    private let uuidClient: UUIDClient
    private let webViewProxyClient: WebViewProxyClient
    private let userDefaultsRepository: UserDefaultsRepository
    private let logService: LogService

    @ObservationIgnored private var eventBridge: Action.EventBridge?
    @ObservationIgnored private var operateWebViewProxy: ((WebViewProxy) -> Void)?
    @ObservationIgnored private var lastDialogClosedDate = Date.distantPast

    public var inputText: String
    public var isPresentedToolbar: Bool
    public var isPresentedZoomPopover: Bool
    public var pageScale: PageScale
    public var isInputingSearchBar: Bool
    public var textSelection: TextSelection?
    public var currentURL: URL?
    public var currentTitle: String?
    public var isPresentedWebDialog: Bool
    public var webDialog: WebDialog?
    public var promptInput: String
    public var customSchemeURL: URL?
    public var isPresentedConfirmationDialog: Bool
    public var isPresentedAlert: Bool
    public let navigationDelegate: BrowserNavigationDelegate
    public let uiDelegate: BrowserUIDelegate
    public var settings: Settings?
    public var bookmarkManagement: BookmarkManagement?

    public let action: (Action) async -> Void

    public init(
        _ appDependencies: AppDependencies,
        eventBridge: Action.EventBridge? = nil,
        inputText: String = "",
        isPresentedToolbar: Bool = true,
        isPresentedZoomPopover: Bool = false,
        pageScale: PageScale = .scale100,
        isInputingSearchBar: Bool = false,
        textSelection: TextSelection? = nil,
        currentURL: URL? = nil,
        currentTitle: String? = nil,
        isPresentedWebDialog: Bool = false,
        webDialog: WebDialog? = nil,
        promptInput: String = "",
        customSchemeURL: URL? = nil,
        isPresentedConfirmationDialog: Bool = false,
        isPresentedAlert: Bool = false,
        browserNavigation: BrowserNavigation? = nil,
        browserUI: BrowserUI? = nil,
        settings: Settings? = nil,
        bookmarkManagement: BookmarkManagement? = nil,
        action: @escaping (Action) async -> Void = { _ in }
    ) {
        self.appStateClient = appDependencies.appStateClient
        self.uiApplicationClient = appDependencies.uiApplicationClient
        self.uuidClient = appDependencies.uuidClient
        self.webViewProxyClient = appDependencies.webViewProxyClient
        self.userDefaultsRepository = .init(appDependencies.userDefaultsClient)
        self.logService = .init(appDependencies)
        self.eventBridge = eventBridge
        self.inputText = inputText
        self.isPresentedToolbar = isPresentedToolbar
        self.isPresentedZoomPopover = isPresentedZoomPopover
        self.pageScale = pageScale
        self.isInputingSearchBar = isInputingSearchBar
        self.textSelection = textSelection
        self.currentURL = currentURL
        self.currentTitle = currentTitle
        self.isPresentedWebDialog = isPresentedWebDialog
        self.webDialog = webDialog
        self.promptInput = promptInput
        self.customSchemeURL = customSchemeURL
        self.isPresentedConfirmationDialog = isPresentedConfirmationDialog
        self.isPresentedAlert = isPresentedAlert
        weak var weakSelf: Browser? = nil
        let browserNavigation = browserNavigation ?? .init(appDependencies, action: {
            await weakSelf?.send(.browserNavigation($0))
        })
        self.navigationDelegate = .init(store: browserNavigation)
        let browserUI = browserUI ?? .init(appDependencies, action: {
            await weakSelf?.send(.browserUI($0))
        })
        self.uiDelegate = .init(store: browserUI)
        self.settings = settings
        self.bookmarkManagement = bookmarkManagement
        self.action = action
        weakSelf = self
    }

    public func reduce(_ action: Action) async {
        switch action {
        case let .task(screenName, eventBridge, webViewProxy):
            logService.notice(.screenView(name: screenName))
            self.eventBridge = eventBridge
            self.webViewProxyClient.setProxy(webViewProxy)

        case let .onChangeURL(url):
            currentURL = url
            if let urlString = url?.absoluteString.removingPercentEncoding {
                inputText = urlString
            }

        case let .onChangeTitle(title):
            currentTitle = title

        case let .onOpenURL(url):
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
            switch components.scheme {
            case "http", "https":
                await webViewProxyClient.load(URLRequest(url: url))
            case "telescopure":
                guard let queryItem = components.queryItems?.first else { return }
                if queryItem.name == "link", var link = queryItem.value {
                    if let fragment = url.fragment {
                        link += "#\(fragment)"
                    }
                    await search(with: link)
                }
                if queryItem.name == "plaintext", let plainText = queryItem.value {
                    // plainText is already removed percent-encoding.
                    await search(with: plainText)
                }
            case .some, .none:
                return
            }

        case let .onSubmit(keyword):
            await search(with: keyword)

        case let .settingsButtonTapped(appDependencies):
            settings = .init(
                appDependencies,
                id: uuidClient.create(),
                action: { [weak self] in
                    await self?.send(.settings($0))
                }
            )

        case .clearSearchButtonTapped:
            inputText = ""

        case .cancelSearchButtonTapped:
            inputText = await webViewProxyClient.url()?.absoluteString ?? ""

        case let .onChangeFocusedField(focusedField):
            isInputingSearchBar = focusedField == .search
            if isInputingSearchBar, let range = inputText.range(of: inputText) {
                textSelection = .init(range: range)
            }
        case .showZoomPopoverButtonTapped:
            isPresentedZoomPopover = true

        case let .zoomButtonTapped(command):
            pageScale = switch command {
            case .zoomReset: .scale100
            case .zoomIn: pageScale.scaleUpped()
            case .zoomOut: pageScale.scaleDowned()
            }

        case .goBackButtonTapped:
            if await webViewProxyClient.canGoBack() {
                await webViewProxyClient.goBack()
            }

        case .goForwardButtonTapped:
            if await webViewProxyClient.canGoForward() {
                await webViewProxyClient.goForward()
            }

        case let .bookmarkButtonTapped(appDependencies):
            bookmarkManagement = .init(
                appDependencies,
                id: uuidClient.create(),
                currentURL: currentURL,
                currentTitle: currentTitle,
                action: { [weak self] in
                    await self?.send(.bookmarkManagement($0))
                }
            )

        case .hideToolbarButtonTapped:
            withAnimation(.easeIn(duration: 0.2)) {
                isPresentedToolbar = false
            }

        case .showToolbarButtonTapped:
            withAnimation(.easeIn(duration: 0.2)) {
                isPresentedToolbar = true
            }

        case .dialogOKButtonTapped:
            guard let webDialog else { return }
            switch webDialog {
            case .alert:
                appStateClient.send(\.alertResponseSubject, input: ())
            case .confirm:
                appStateClient.send(\.confirmResponseSubject, input: true)
            case .prompt:
                appStateClient.send(\.promptResponseSubject, input: promptInput)
            }

        case .dialogCancelButtonTapped:
            guard let webDialog else { return }
            switch webDialog {
            case .alert:
                appStateClient.send(\.alertResponseSubject, input: ())
            case .confirm:
                appStateClient.send(\.confirmResponseSubject, input: false)
            case .prompt:
                appStateClient.send(\.promptResponseSubject, input: nil)
            }

        case let .onChangeIsPresentedWebDialog(isPresented):
            if !isPresented {
                lastDialogClosedDate = .now
            }

        case let .confirmButtonTapped(url):
            let openURLResult = await uiApplicationClient.open(url)
            guard !openURLResult else { return }
            isPresentedAlert = true

        case let .browserNavigation(.decidePolicyFor(request)):
            guard let requestURL = request.url else {
                appStateClient.send(\.actionPolicySubject, input: .cancel)
                return
            }
            guard ["http", "https", "blob", "file", "about"].contains(requestURL.scheme) else {
                appStateClient.send(\.actionPolicySubject, input: .cancel)
                customSchemeURL = requestURL
                isPresentedConfirmationDialog = true
                return
            }
            appStateClient.send(\.actionPolicySubject, input: .allow)

        case let .browserNavigation(.didFailProvisionalNavigation(error)),
            let .browserNavigation(.didFail(error)):
            guard (error as NSError).code != NSURLErrorCancelled else {
                return
            }
            await loadErrorPage(with: error)

        case let .browserUI(.runJavaScriptAlertPanel(message)):
            await presentWebDialog(.alert(message))

        case let .browserUI(.runJavaScriptConfirmPanel(message)):
            await presentWebDialog(.confirm(message))

        case let .browserUI(.runJavaScriptTextInputPanel(prompt, defaultText)):
            await presentWebDialog(.prompt(prompt, defaultText ?? ""))

        case .settings(.doneButtonTapped):
            settings = nil

        case .settings:
            break

        case let .bookmarkManagement(.bookmarkItem(.openBookmarkButtonTapped(url))):
            bookmarkManagement = nil
            await webViewProxyClient.load(URLRequest(url: url))

        case .bookmarkManagement(.doneButtonTapped):
            bookmarkManagement = nil

        case .bookmarkManagement:
            break
        }
    }

    private func search(with text: String) async {
        let searchEngine = userDefaultsRepository.searchEngine ?? .google
        let url: URL? = if text.isEmpty {
            URL(string: searchEngine.url)
        } else if let url = URLComponents(string: text)?.url, let scheme = url.scheme {
            switch scheme.lowercased() {
            case "http", "https":
                URL(string: text)
            default:
                url
            }
        } else {
            URLComponents(string: searchEngine.urlWithQuery(keywords: text))?.url
        }
        if let url {
            await webViewProxyClient.load(URLRequest(url: url))
        }
    }

    private func loadErrorPage(with error: any Error) async {
        guard let fileURL = eventBridge?.getResourceURL?("error", "html"),
              var htmlString = try? String(contentsOf: fileURL, encoding: .utf8) else {
            fatalError("Could not load error.html")
        }
        if let urlError = error as? URLError {
            htmlString = htmlString.replacingOccurrences(of: String.errorMessage, with: urlError.localizedDescription)
            await webViewProxyClient.loadHTMLString(htmlString, urlError.failingURL)
        } else {
            htmlString = htmlString.replacingOccurrences(of: String.errorMessage, with: error.localizedDescription)
            await webViewProxyClient.loadHTMLString(htmlString, URL(string: inputText))
        }
    }

    private func presentWebDialog(_ webDialog: WebDialog) async {
        while lastDialogClosedDate.distance(to: .now) < 0.1 {
            try? await Task.sleep(for: .seconds(0.1))
        }
        self.webDialog = webDialog
        isPresentedWebDialog = true
    }

    public enum Action: Sendable {
        case task(String, EventBridge, WebViewProxy)
        case onChangeURL(URL?)
        case onChangeTitle(String?)
        case onOpenURL(URL)
        case onSubmit(String)
        case settingsButtonTapped(AppDependencies)
        case clearSearchButtonTapped
        case cancelSearchButtonTapped
        case onChangeFocusedField(FocusedField?)
        case showZoomPopoverButtonTapped
        case zoomButtonTapped(PageZoomCommand)
        case goBackButtonTapped
        case goForwardButtonTapped
        case bookmarkButtonTapped(AppDependencies)
        case hideToolbarButtonTapped
        case showToolbarButtonTapped
        case dialogOKButtonTapped
        case dialogCancelButtonTapped
        case onChangeIsPresentedWebDialog(Bool)
        case confirmButtonTapped(URL)
        case browserNavigation(BrowserNavigation.Action)
        case browserUI(BrowserUI.Action)
        case settings(Settings.Action)
        case bookmarkManagement(BookmarkManagement.Action)

        public struct EventBridge: Sendable {
            public var getResourceURL: (@MainActor @Sendable (String, String) -> URL?)?

            public init(getResourceURL: @escaping @MainActor @Sendable (String, String) -> URL?) {
                self.getResourceURL = getResourceURL
            }
        }
    }
}
