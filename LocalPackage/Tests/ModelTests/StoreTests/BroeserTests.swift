import Foundation
import os
import Testing

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

    @MainActor @Test
    func send_browserNavigation_decidePolicyFor_requestURL_is_nil() async {
        var continuation: CheckedContinuation<PolicyResult, Never>!
        let setContinuation = { continuation = $0 }
        let continuationTask = Task {
            await withCheckedContinuation { continuation in
                setContinuation(continuation)
            }
        }
        await Task.yield()
        let sut = Browser(.testDependencies())
        var request = URLRequest(url: URL(string: "https://test.com")!)
        request.url = nil
        await sut.send(.browserNavigation(.decidePolicyFor(request, .init(), continuation)))
        let actual = await continuationTask.value
        #expect(actual.0 == .cancel)
    }

    @MainActor @Test(arguments: [
        "http://test.com",
        "https://test.com",
        "blob:https://test.com/0",
        "file:///path/to/file",
        "about:blank",
    ] as [String])
    func send_browserNavigation_decidePolicyFor_valid_scheme(_ urlString: String) async {
        var continuation: CheckedContinuation<PolicyResult, Never>!
        let setContinuation = { continuation = $0 }
        let continuationTask = Task {
            await withCheckedContinuation { continuation in
                setContinuation(continuation)
            }
        }
        await Task.yield()
        let sut = Browser(.testDependencies())
        let request = URLRequest(url: URL(string: urlString)!)
        await sut.send(.browserNavigation(.decidePolicyFor(request, .init(), continuation)))
        let actual = await continuationTask.value
        #expect(actual.0 == .allow)
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
        var continuation: CheckedContinuation<PolicyResult, Never>!
        let setContinuation = { continuation = $0 }
        let continuationTask = Task {
            await withCheckedContinuation { continuation in
                setContinuation(continuation)
            }
        }
        await Task.yield()
        let sut = TestStore {
            Browser(
                .testDependencies(
                    uiApplicationClient: testDependency(of: UIApplicationClient.self) {
                        $0.open = { _ in true }
                    }
                ),
                eventBridge: .init(
                    getLocalizedString: { _ in "test" },
                    getResourceURL: { _, _ in nil }
                ),
                action: $0
            )
        }
        let request = URLRequest(url: URL(string: urlString)!)
        let task = Task {
            await sut.send(.browserNavigation(.decidePolicyFor(request, .init(), continuation)))
        }
        await Task.yield()
        await sut.receive { action in
            if case let .onRequestConfirm("test", continuation) = action {
                continuation.resume(returning: true)
                return true
            } else {
                return false
            }
        }
        await task.value
        let actual = await continuationTask.value
        #expect(actual.0 == .cancel)
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
            eventBridge: .init(
                getLocalizedString: { _ in "" },
                getResourceURL: { _, _ in Bundle.module.url(forResource: "error", withExtension: "html")! }
            )
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
            eventBridge: .init(
                getLocalizedString: { _ in "" },
                getResourceURL: { _, _ in Bundle.module.url(forResource: "error", withExtension: "html")! }
            ),
            inputText: "https://test.com"
        )
        let error = CocoaError(.fileReadUnknown)
        await sut.send(.browserNavigation(.didFailProvisionalNavigation(error)))
        #expect(htmlString.withLock(\.self) == "<h3>The file couldn’t be opened.</h3>\n")
        #expect(baseURL.withLock(\.self) == URL(string: "https://test.com")!)
    }

    @MainActor @Test
    func send_browserUI_runJavaScriptAlertPanelWithMessage() async {
        var continuation: CheckedContinuation<Void, Never>!
        let setContinuation = { continuation = $0 }
        let continuationTask = Task {
            await withCheckedContinuation { continuation in
                setContinuation(continuation)
            }
        }
        await Task.yield()
        let sut = TestStore { Browser(.testDependencies(), action: $0) }
        await sut.send(.browserUI(.runJavaScriptAlertPanelWithMessage("test", continuation)))
        await sut.receive {
            if case .onRequestAlert = $0 { true } else { false }
        }
        continuation.resume()
        continuationTask.cancel()
        let actualWebDialog = if case .alert = sut.webDialog { true } else { false }
        #expect(actualWebDialog)
        #expect(sut.isPresentedWebDialog)
    }

    @MainActor @Test
    func send_browserUI_runJavaScriptConfirmPanelWithMessage() async {
        var continuation: CheckedContinuation<Bool, Never>!
        let setContinuation = { continuation = $0 }
        let continuationTask = Task {
            await withCheckedContinuation { continuation in
                setContinuation(continuation)
            }
        }
        await Task.yield()
        let sut = TestStore { Browser(.testDependencies(), action: $0) }
        await sut.send(.browserUI(.runJavaScriptConfirmPanelWithMessage("test", continuation)))
        await sut.receive {
            if case .onRequestConfirm = $0 { true } else { false }
        }
        continuation.resume(returning: true)
        continuationTask.cancel()
        let actualWebDialog = if case .confirm = sut.webDialog { true } else { false }
        #expect(actualWebDialog)
        #expect(sut.isPresentedWebDialog)
    }

    @MainActor @Test
    func send_browserUI_runJavaScriptTextInputPanelWithPrompt() async {
        var continuation: CheckedContinuation<String?, Never>!
        let setContinuation = { continuation = $0 }
        let continuationTask = Task {
            await withCheckedContinuation { continuation in
                setContinuation(continuation)
            }
        }
        await Task.yield()
        let sut = TestStore { Browser(.testDependencies(), action: $0) }
        await sut.send(.browserUI(.runJavaScriptTextInputPanelWithPrompt("test", nil, continuation)))
        await sut.receive {
            if case .onRequestPrompt = $0 { true } else { false }
        }
        continuation.resume(returning: "dummy")
        continuationTask.cancel()
        let actualWebDialog = if case .prompt = sut.webDialog { true } else { false }
        #expect(actualWebDialog)
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
