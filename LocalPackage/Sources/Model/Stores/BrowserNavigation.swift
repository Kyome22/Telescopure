import Observation
import WebKit

public typealias PolicyResult = (WKNavigationActionPolicy, WKWebpagePreferences)

@MainActor @Observable public final class BrowserNavigation: Composable {
    public let action: (Action) async -> Void

    public init(action: @escaping (Action) async -> Void) {
        self.action = action
    }

    public func reduce(_ action: Action) async {}

    public enum Action: Sendable {
        case decidePolicyFor(URLRequest, WKWebpagePreferences, CheckedContinuation<PolicyResult, Never>)
        case didFailProvisionalNavigation(any Error)
    }
}

public final class BrowserNavigationDelegate: NSObject, WKNavigationDelegate, ObservableObject {
    private var store: BrowserNavigation

    public init(store: BrowserNavigation) {
        self.store = store
    }

    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        preferences: WKWebpagePreferences
    ) async -> (WKNavigationActionPolicy, WKWebpagePreferences) {
        await withCheckedContinuation { continuation in
            Task { @MainActor [store] in
                await store.send(.decidePolicyFor(navigationAction.request, preferences, continuation))
            }
        }
    }

    public func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: any Error
    ) {
        Task { @MainActor [store] in
            await store.send(.didFailProvisionalNavigation(error))
        }
    }
}
