import DataSource
import Observation
import SwiftUI
import WebUI

@MainActor @Observable public final class Browser: ObservableObject {
    private let uiApplicationClient: UIApplicationClient
    private let uuidClient: UUIDClient
    private let webViewProxyClient: WebViewProxyClient
    private let userDefaultsRepository: UserDefaultsRepository
    private let logService: LogService

    @ObservationIgnored private var getLocalizedString: ((Action.ResourceBridge) -> String)?
    @ObservationIgnored private var getResourceURL: ((String, String) -> URL?)?
    @ObservationIgnored private var operateWebViewProxy: ((WebViewProxy) -> Void)?

    public var browserNavigation = BrowserNavigation(action: { _ in })
    public var browserUI = BrowserUI(action: { _ in })
    public var inputText: String
    public var isPresentedToolBar: Bool
    public var settings: Settings?
    public var bookmarkManagement: BookmarkManagement?
    public var currentURL: URL?
    public var currentTitle: String?
    public var isPresentedWebDialog: Bool
    public var webDialog: WebDialog?
    public var promptInput: String

    public init(
        _ appDependencies: AppDependencies,
        inputText: String = "",
        isPresentedToolBar: Bool = true,
        settings: Settings? = nil,
        bookmarkManagement: BookmarkManagement? = nil,
        currentURL: URL? = nil,
        currentTitle: String? = nil,
        isPresentedWebDialog: Bool = false,
        webDialog: WebDialog? = nil,
        promptInput: String = ""
    ) {
        self.inputText = inputText
        self.isPresentedToolBar = isPresentedToolBar
        self.settings = settings
        self.bookmarkManagement = bookmarkManagement
        self.currentURL = currentURL
        self.currentTitle = currentTitle
        self.isPresentedWebDialog = isPresentedWebDialog
        self.webDialog = webDialog
        self.promptInput = promptInput
        self.uiApplicationClient = appDependencies.uiApplicationClient
        self.uuidClient = appDependencies.uuidClient
        self.webViewProxyClient = appDependencies.webViewProxyClient
        self.userDefaultsRepository = .init(appDependencies.userDefaultsClient)
        self.logService = .init(appDependencies)
        self.browserNavigation = .init(action: { [weak self] in
            await self?.send(.browserNavigation($0))
        })
        self.browserUI = .init(action: { [weak self] in
            await self?.send(.browserUI($0))
        })
    }

    public func send(_ action: Action) async {
        switch action {
        case let .task(eventBridge, webViewProxy):
            self.getLocalizedString = eventBridge.getLocalizedString
            self.getResourceURL = eventBridge.getResourceURL
            self.webViewProxyClient.setProxy(webViewProxy)

        case let .onChangeURL(url):
            currentURL = url
            if let urlString = url?.absoluteString.removingPercentEncoding {
                inputText = urlString
            }

        case let .onChangeTitle(title):
            currentTitle = title

        case let .onOpenURL(url):
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let queryItem = components.queryItems?.first
            else { return }
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

        case .hideToolBarButtonTapped:
            withAnimation(.easeIn(duration: 0.2)) {
                isPresentedToolBar = false
            }

        case .showToolBarButtonTapped:
            withAnimation(.easeIn(duration: 0.2)) {
                isPresentedToolBar = true
            }

        case let .onRequestAlert(message, continuation):
            webDialog = .alert(message, continuation)
            isPresentedWebDialog = true

        case let .onRequestConfirm(message, continuation):
            webDialog = .confirm(message, continuation)
            isPresentedWebDialog = true

        case let .onRequestPrompt(prompt, defaultText, continuation):
            webDialog = .prompt(prompt, defaultText ?? "", continuation)
            isPresentedWebDialog = true

        case .dialogOKButtonTapped:
            guard let webDialog else { return }
            switch webDialog {
            case let .alert(_, continuation):
                continuation.resume()
            case let .confirm(_, continuation):
                continuation.resume(returning: true)
            case let .prompt(_, _, continuation):
                continuation.resume(returning: promptInput)
            }

        case .dialogCancelButtonTapped:
            guard let webDialog else { return }
            switch webDialog {
            case let .alert(_, continuation):
                continuation.resume()
            case let .confirm(_, continuation):
                continuation.resume(returning: false)
            case let .prompt(_, _, continuation):
                continuation.resume(returning: nil)
            }

        case let .browserNavigation(.decidePolicyFor(request, preferences, continuation)):
            preferences.preferredContentMode = .mobile
            guard let requestURL = request.url else {
                continuation.resume(returning: (.cancel, preferences))
                return
            }
            guard ["http", "https", "blob", "file", "about"].contains(requestURL.scheme) else {
                continuation.resume(returning: (.cancel, preferences))
                guard let message = getLocalizedString?(.openExternalApp(requestURL.absoluteString)) else {
                    return
                }
                let confirmResult = await withCheckedContinuation { continuation in
                    Task { @MainActor [weak self] in
                        await self?.send(.onRequestConfirm(message, continuation))
                    }
                }
                guard confirmResult else {
                    return
                }
                let openURLResult = await uiApplicationClient.open(requestURL)
                guard !openURLResult, let message = getLocalizedString?(.failedToOpenExternalApp) else {
                    return
                }
                await withCheckedContinuation { continuation in
                    Task { @MainActor [weak self] in
                        await self?.send(.onRequestAlert(message, continuation))
                    }
                }
                return
            }
            continuation.resume(returning: (.allow, preferences))

        case let .browserNavigation(.didFailProvisionalNavigation(error)):
            guard let fileURL = getResourceURL?("error", "html"),
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

        case let .browserUI(.runJavaScriptAlertPanelWithMessage(message, continuation)):
            await send(.onRequestAlert(message, continuation))

        case let .browserUI(.runJavaScriptConfirmPanelWithMessage(message, continuation)):
            await send(.onRequestConfirm(message, continuation))

        case let .browserUI(.runJavaScriptTextInputPanelWithPrompt(prompt, defaultText, continuation)):
            await send(.onRequestPrompt(prompt, defaultText, continuation))

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

    public enum Action {
        case task(EventBridge, WebViewProxy)
        case onChangeURL(URL?)
        case onChangeTitle(String?)
        case onOpenURL(URL)
        case onSubmit(String)
        case settingsButtonTapped(AppDependencies)
        case clearSearchButtonTapped
        case goBackButtonTapped
        case goForwardButtonTapped
        case bookmarkButtonTapped(AppDependencies)
        case hideToolBarButtonTapped
        case showToolBarButtonTapped
        case onRequestAlert(String, CheckedContinuation<Void, Never>)
        case onRequestConfirm(String, CheckedContinuation<Bool, Never>)
        case onRequestPrompt(String, String?, CheckedContinuation<String?, Never>)
        case dialogOKButtonTapped
        case dialogCancelButtonTapped
        case browserNavigation(BrowserNavigation.Action)
        case browserUI(BrowserUI.Action)
        case settings(Settings.Action)
        case bookmarkManagement(BookmarkManagement.Action)

        public struct EventBridge {
            public var getLocalizedString: (ResourceBridge) -> String
            public var getResourceURL: (String, String) -> URL?

            public init(
                getLocalizedString: @escaping (ResourceBridge) -> String,
                getResourceURL: @escaping (String, String) -> URL?
            ) {
                self.getLocalizedString = getLocalizedString
                self.getResourceURL = getResourceURL
            }
        }

        public enum ResourceBridge {
            case openExternalApp(String)
            case failedToOpenExternalApp
        }
    }
}
