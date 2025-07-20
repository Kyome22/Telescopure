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
                    return "google"
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
                    return "google"
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
                    return "bing"
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
