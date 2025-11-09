import Foundation
import os
import Testing
import WebKit

@testable import DataSource
@testable import Model

struct BrowserTests {
    @MainActor @Test
    func send_onChangeURL() async {
        let sut = Browser(.testDependencies())
        await sut.send(.onChangeURL(URL(string: "https://example.com?text=Hello%20World")))
        #expect(sut.currentURL == URL(string: "https://example.com?text=Hello%20World")!)
        #expect(sut.inputText == "https://example.com?text=Hello World")
    }

    @MainActor @Test
    func send_onChangeTitle() async {
        let sut = Browser(.testDependencies())
        await sut.send(.onChangeTitle("Example"))
        #expect(sut.currentTitle == "Example")
    }

    @MainActor @Test
    func send_onOpenURL_https_scheme() async {
        let request = OSAllocatedUnfairLock<URLRequest?>(initialState: nil)
        let sut = Browser(.testDependencies(
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.string = { key in
                    guard key == "search-engine" else { return nil }
                    return SearchEngine.google.rawValue
                }
            },
            webViewProxyClient: testDependency(of: WebViewProxyClient.self) {
                $0.load = { value in
                    request.withLock { $0 = value }
                }
            }
        ))
        await sut.send(.onOpenURL(URL(string: "https://example.com")!))
        #expect(request.withLock(\.self)?.url == URL(string: "https://example.com")!)
    }

    @MainActor @Test
    func send_onOpenURL_link() async {
        let request = OSAllocatedUnfairLock<URLRequest?>(initialState: nil)
        let sut = Browser(.testDependencies(
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.string = { key in
                    guard key == "search-engine" else { return nil }
                    return SearchEngine.google.rawValue
                }
            },
            webViewProxyClient: testDependency(of: WebViewProxyClient.self) {
                $0.load = { value in
                    request.withLock { $0 = value }
                }
            }
        ))
        await sut.send(.onOpenURL(URL(string: "telescopure://?link=https://example.com")!))
        #expect(request.withLock(\.self)?.url == URL(string: "https://example.com")!)
    }

    @MainActor @Test
    func send_onOpenURL_plaintext() async {
        let request = OSAllocatedUnfairLock<URLRequest?>(initialState: nil)
        let sut = Browser(.testDependencies(
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.string = { key in
                    guard key == "search-engine" else { return nil }
                    return SearchEngine.google.rawValue
                }
            },
            webViewProxyClient: testDependency(of: WebViewProxyClient.self) {
                $0.load = { value in
                    request.withLock { $0 = value }
                }
            }
        ))
        await sut.send(.onOpenURL(URL(string: "telescopure://?plaintext=dummy")!))
        #expect(request.withLock(\.self)?.url == URL(string: "https://www.google.com/search?q=dummy")!)
    }

    @MainActor @Test
    func send_onSubmit() async {
        let request = OSAllocatedUnfairLock<URLRequest?>(initialState: nil)
        let sut = Browser(.testDependencies(
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.string = { key in
                    guard key == "search-engine" else { return nil }
                    return SearchEngine.bing.rawValue
                }
            },
            webViewProxyClient: testDependency(of: WebViewProxyClient.self) {
                $0.load = { value in
                    request.withLock { $0 = value }
                }
            }
        ))
        await sut.send(.onSubmit("dummy"))
        #expect(request.withLock(\.self)?.url == URL(string: "https://www.bing.com/search?q=dummy")!)
    }

    @MainActor @Test
    func send_clearSearchButtonTapped() async {
        let sut = Browser(.testDependencies(), inputText: "dummy")
        await sut.send(.clearSearchButtonTapped)
        #expect(sut.inputText.isEmpty)
    }

    @MainActor @Test
    func send_cancelSearchButtonTapped() async {
        let sut = Browser(.testDependencies(
            webViewProxyClient: testDependency(of: WebViewProxyClient.self) {
                $0.url = { URL(string: "https://www.bing.com/search?q=dummy") }
            }
        ))
        await sut.send(.cancelSearchButtonTapped)
        #expect(sut.inputText == "https://www.bing.com/search?q=dummy")
    }

    @MainActor @Test
    func send_showZoomPopoverButtonTapped() async {
        let sut = Browser(.testDependencies())
        await sut.send(.showZoomPopoverButtonTapped)
        #expect(sut.isPresentedZoomPopover)
    }

    @MainActor @Test(arguments: [
        .init(pageScale: .scale150, pageZoomCommand: .zoomReset, expectPageScale: .scale100),
        .init(pageScale: .scale100, pageZoomCommand: .zoomIn, expectPageScale: .scale110),
        .init(pageScale: .scale300, pageZoomCommand: .zoomIn, expectPageScale: .scale300),
        .init(pageScale: .scale100, pageZoomCommand: .zoomOut, expectPageScale: .scale90),
        .init(pageScale: .scale50, pageZoomCommand: .zoomOut, expectPageScale: .scale50),
    ] as [ZoomButtonProperty])
    func send_zoomButtonTapped(_ property: ZoomButtonProperty) async {
        let sut = Browser(.testDependencies(), pageScale: property.pageScale)
        await sut.send(.zoomButtonTapped(property.pageZoomCommand))
        #expect(sut.pageScale == property.expectPageScale)
    }

    @MainActor @Test
    func send_goBackButtonTapped() async {
        let goBackCount = OSAllocatedUnfairLock(initialState: 0)
        let sut = Browser(.testDependencies(
            webViewProxyClient: testDependency(of: WebViewProxyClient.self) {
                $0.canGoBack = { true }
                $0.goBack = { goBackCount.withLock { $0 += 1 } }
            }
        ))
        await sut.send(.goBackButtonTapped)
        #expect(goBackCount.withLock(\.self) == 1)
    }

    @MainActor @Test
    func send_goForwardButtonTapped() async {
        let goForwardCount = OSAllocatedUnfairLock(initialState: 0)
        let sut = Browser(.testDependencies(
            webViewProxyClient: testDependency(of: WebViewProxyClient.self) {
                $0.canGoForward = { true }
                $0.goForward = { goForwardCount.withLock { $0 += 1 } }
            }
        ))
        await sut.send(.goForwardButtonTapped)
        #expect(goForwardCount.withLock(\.self) == 1)
    }

    @MainActor @Test(arguments: [
        .init(webDialog: .alert("test"), expectAlert: 1),
        .init(webDialog: .confirm("test"), expectConfirm: true),
        .init(webDialog: .prompt("test", ""), promptInput: "input", expectPrompt: .some("input")),
    ] as [DialogProperty])
    func send_dialogOKButtonTapped(_ property: DialogProperty) async {
        let appState = OSAllocatedUnfairLock<AppState>(initialState: .init())
        let alertResponseCount = OSAllocatedUnfairLock<Int>(initialState: .zero)
        let confirmResponse = OSAllocatedUnfairLock<Bool?>(initialState: nil)
        let promptResponse = OSAllocatedUnfairLock<String??>(initialState: nil)
        let sut = Browser(
            .testDependencies(
                appStateClient: .testDependency(appState, receive: .init(action: {
                    switch ($0, $1) {
                    case (\AppState.alertResponseSubject, _ as Void):
                        alertResponseCount.withLock { $0 += 1 }
                    case (\AppState.confirmResponseSubject, let value as Bool):
                        confirmResponse.withLock { $0 = value }
                    case (\AppState.promptResponseSubject, let value as String?):
                        promptResponse.withLock { $0 = value }
                    default:
                        break
                    }
                }))
            ),
            webDialog: property.webDialog,
            promptInput: property.promptInput
        )
        await sut.send(.dialogOKButtonTapped)
        #expect(alertResponseCount.withLock(\.self) == property.expectAlert)
        #expect(confirmResponse.withLock(\.self) == property.expectConfirm)
        #expect(promptResponse.withLock(\.self) == property.expectPrompt)
    }

    @MainActor @Test(arguments: [
        .init(webDialog: .alert("test"), expectAlert: 1),
        .init(webDialog: .confirm("test"), expectConfirm: false),
        .init(webDialog: .prompt("test", ""), promptInput: "input", expectPrompt: .some(nil)),
    ] as [DialogProperty])
    func send_dialogCancelButtonTapped(_ property: DialogProperty) async {
        let appState = OSAllocatedUnfairLock<AppState>(initialState: .init())
        let alertResponseCount = OSAllocatedUnfairLock<Int>(initialState: .zero)
        let confirmResponse = OSAllocatedUnfairLock<Bool?>(initialState: nil)
        let promptResponse = OSAllocatedUnfairLock<String??>(initialState: nil)
        let sut = Browser(
            .testDependencies(
                appStateClient: .testDependency(appState, receive: .init(action: {
                    switch ($0, $1) {
                    case (\AppState.alertResponseSubject, _ as Void):
                        alertResponseCount.withLock { $0 += 1 }
                    case (\AppState.confirmResponseSubject, let value as Bool):
                        confirmResponse.withLock { $0 = value }
                    case (\AppState.promptResponseSubject, let value as String?):
                        promptResponse.withLock { $0 = value }
                    default:
                        break
                    }
                }))
            ),
            webDialog: property.webDialog,
            promptInput: property.promptInput
        )
        await sut.send(.dialogCancelButtonTapped)
        #expect(alertResponseCount.withLock(\.self) == property.expectAlert)
        #expect(confirmResponse.withLock(\.self) == property.expectConfirm)
        #expect(promptResponse.withLock(\.self) == property.expectPrompt)
    }

    @MainActor @Test
    func send_browserNavigation_decidePolicyFor_requestURL_is_nil() async {
        let appState = OSAllocatedUnfairLock<AppState>(initialState: .init())
        let actionPolicy = OSAllocatedUnfairLock<WKNavigationActionPolicy?>(initialState: nil)
        let sut = Browser(.testDependencies(
            appStateClient: .testDependency(appState, receive: .init(action: {
                switch ($0, $1) {
                case (\AppState.actionPolicySubject, let value as WKNavigationActionPolicy):
                    actionPolicy.withLock { $0 = value }
                default:
                    break
                }
            }))
        ))
        var request = URLRequest(url: URL(string: "https://test.com")!)
        request.url = nil
        await sut.send(.browserNavigation(.decidePolicyFor(request)))
        #expect(actionPolicy.withLock(\.self) == .cancel)
    }

    @MainActor @Test(arguments: [
        "http://test.com",
        "https://test.com",
        "blob:https://test.com/0",
        "file:///path/to/file",
        "about:blank",
    ] as [String])
    func send_browserNavigation_decidePolicyFor_valid_scheme(_ urlString: String) async {
        let appState = OSAllocatedUnfairLock<AppState>(initialState: .init())
        let actionPolicy = OSAllocatedUnfairLock<WKNavigationActionPolicy?>(initialState: nil)
        let sut = Browser(.testDependencies(
            appStateClient: .testDependency(appState, receive: .init(action: {
                switch ($0, $1) {
                case (\AppState.actionPolicySubject, let value as WKNavigationActionPolicy):
                    actionPolicy.withLock { $0 = value }
                default:
                    break
                }
            }))
        ))
        let request = URLRequest(url: URL(string: urlString)!)
        await sut.send(.browserNavigation(.decidePolicyFor(request)))
        #expect(actionPolicy.withLock(\.self) == .allow)
    }

    @MainActor @Test(arguments: [
        "sms://",
        "tel://",
        "facetime://",
        "facetime-audio://",
        "imessage://",
        "mailto://",
    ] as [String])
    func send_browserNavigation_decidePolicyFor_invalid_scheme(_ urlString: String) async {
        let appState = OSAllocatedUnfairLock<AppState>(initialState: .init())
        let actionPolicy = OSAllocatedUnfairLock<WKNavigationActionPolicy?>(initialState: nil)
        let sut = Browser(.testDependencies(
            appStateClient: .testDependency(appState, receive: .init(action: {
                switch ($0, $1) {
                case (\AppState.actionPolicySubject, let value as WKNavigationActionPolicy):
                    actionPolicy.withLock { $0 = value }
                default:
                    break
                }
            }))
        ))
        let request = URLRequest(url: URL(string: urlString)!)
        await sut.send(.browserNavigation(.decidePolicyFor(request)))
        #expect(actionPolicy.withLock(\.self) == .cancel)
        #expect(sut.customSchemeURL == request.url)
        #expect(sut.isPresentedConfirmationDialog)
    }

    @MainActor @Test
    func send_browserNavigation_didFailProvisionalNavigation_URLError() async {
        let htmlString = OSAllocatedUnfairLock<String?>(initialState: nil)
        let baseURL = OSAllocatedUnfairLock<URL?>(initialState: nil)
        let sut = Browser(
            .testDependencies(
                webViewProxyClient: testDependency(of: WebViewProxyClient.self) {
                    $0.loadHTMLString = { text, url in
                        htmlString.withLock { $0 = text }
                        baseURL.withLock { $0 = url }
                    }
                }
            ),
            eventBridge: .init(getResourceURL: { _, _ in
                Bundle.module.url(forResource: "error", withExtension: "html")!
            })
        )
        let error = URLError(.badURL, userInfo: [NSURLErrorFailingURLErrorKey: URL(string: "https://test.com")!])
        await sut.send(.browserNavigation(.didFailProvisionalNavigation(error)))
        #expect(htmlString.withLock(\.self) == "<h3>The operation couldn’t be completed. (NSURLErrorDomain error -1000.)</h3>\n")
        #expect(baseURL.withLock(\.self) == URL(string: "https://test.com")!)
    }

    @MainActor @Test
    func send_browserNavigation_didFailProvisionalNavigation_not_URLError() async {
        let htmlString = OSAllocatedUnfairLock<String?>(initialState: nil)
        let baseURL = OSAllocatedUnfairLock<URL?>(initialState: nil)
        let sut = Browser(
            .testDependencies(
                webViewProxyClient: testDependency(of: WebViewProxyClient.self) {
                    $0.loadHTMLString = { text, url in
                        htmlString.withLock { $0 = text }
                        baseURL.withLock { $0 = url }
                    }
                }
            ),
            eventBridge: .init(getResourceURL: { _, _ in
                Bundle.module.url(forResource: "error", withExtension: "html")!
            }),
            inputText: "https://test.com"
        )
        let error = CocoaError(.fileReadUnknown)
        await sut.send(.browserNavigation(.didFailProvisionalNavigation(error)))
        #expect(htmlString.withLock(\.self) == "<h3>The file couldn’t be opened.</h3>\n")
        #expect(baseURL.withLock(\.self) == URL(string: "https://test.com")!)
    }

    @MainActor @Test
    func send_browserUI_runJavaScriptAlertPanel() async {
        let appState = OSAllocatedUnfairLock<AppState>(initialState: .init())
        let sut = Browser(.testDependencies(
            appStateClient: .testDependency(appState)
        ))
        await sut.send(.browserUI(.runJavaScriptAlertPanel("test")))
        #expect(sut.webDialog == .alert("test"))
        #expect(sut.isPresentedWebDialog)
    }

    @MainActor @Test
    func send_browserUI_runJavaScriptConfirmPanel() async {
        let appState = OSAllocatedUnfairLock<AppState>(initialState: .init())
        let sut = Browser(.testDependencies(
            appStateClient: .testDependency(appState)
        ))
        await sut.send(.browserUI(.runJavaScriptConfirmPanel("test")))
        #expect(sut.webDialog == .confirm("test"))
        #expect(sut.isPresentedWebDialog)
    }

    @MainActor @Test
    func send_browserUI_runJavaScriptTextInputPanel() async {
        let appState = OSAllocatedUnfairLock<AppState>(initialState: .init())
        let sut = Browser(.testDependencies(
            appStateClient: .testDependency(appState)
        ))
        await sut.send(.browserUI(.runJavaScriptTextInputPanel("test", nil)))
        #expect(sut.webDialog == .prompt("test", ""))
        #expect(sut.isPresentedWebDialog)
    }

    @MainActor @Test
    func send_bookmarkManagement_bookmarkItem_openBookmarkButtonTapped() async {
        let request = OSAllocatedUnfairLock<URLRequest?>(initialState: nil)
        let sut = Browser(.testDependencies(
            webViewProxyClient: testDependency(of: WebViewProxyClient.self) {
                $0.load = { value in
                    request.withLock { $0 = value }
                }
            }
        ))
        let url = URL(string: "http://example.com")!
        await sut.send(.bookmarkManagement(.bookmarkItem(.openBookmarkButtonTapped(url))))
        #expect(sut.bookmarkManagement == nil)
        #expect(request.withLock(\.self)?.url == url)
    }

    @MainActor @Test
    func send_bookmarkManagement_doneButtonTapped() async {
        let sut = Browser(.testDependencies())
        await sut.send(.bookmarkManagement(.doneButtonTapped))
        #expect(sut.bookmarkManagement == nil)
    }
}

struct ZoomButtonProperty: Sendable {
    var pageScale: PageScale
    var pageZoomCommand: PageZoomCommand
    var expectPageScale: PageScale
}

struct DialogProperty: Sendable {
    var webDialog: WebDialog
    var promptInput: String = ""
    var expectAlert: Int = .zero
    var expectConfirm: Bool? = nil
    var expectPrompt: String?? = nil
}
