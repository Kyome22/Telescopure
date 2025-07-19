import Observation
import WebKit

public typealias PolicyResult = (WKNavigationActionPolicy, WKWebpagePreferences)

@MainActor @Observable public final class BrowserNavigation {
    private let action: @MainActor (Action) async -> Void

    public init(action: @MainActor @escaping (Action) async -> Void) {
        self.action = action
    }

    public func send(_ action: Action) async {
        await self.action(action)
    }

    public enum Action {
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
