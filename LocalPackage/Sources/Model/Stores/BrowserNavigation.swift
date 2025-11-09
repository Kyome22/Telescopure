import DataSource
import Observation
import WebKit

@MainActor @Observable public final class BrowserNavigation {
    private let appStateClient: AppStateClient
    let action: (Action) async -> Void

    init(
        _ appDependencies: AppDependencies,
        action: @escaping (Action) async -> Void
    ) {
        self.appStateClient = appDependencies.appStateClient
        self.action = action
    }

    func decidePolicy(for request: URLRequest) async -> WKNavigationActionPolicy {
        await action(.decidePolicyFor(request))
        for await value in appStateClient.withLock(\.actionPolicySubject.values) {
            return value
        }
        return .cancel
    }

    func didFailProvisionalNavigation(error: any Error) async {
        await action(.didFailProvisionalNavigation(error))
    }

    func didFail(error: any Error) async {
        await action(.didFail(error))
    }

    public enum Action: Sendable {
        case decidePolicyFor(URLRequest)
        case didFailProvisionalNavigation(any Error)
        case didFail(any Error)
    }
}

public final class BrowserNavigationDelegate: NSObject, WKNavigationDelegate, ObservableObject {
    private var store: BrowserNavigation

    init(store: BrowserNavigation) {
        self.store = store
    }

    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        preferences: WKWebpagePreferences
    ) async -> (WKNavigationActionPolicy, WKWebpagePreferences) {
        preferences.preferredContentMode = .mobile
        let actionPolicy = await store.decidePolicy(for: navigationAction.request)
        return (actionPolicy, preferences)
    }

    public func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: any Error
    ) {
        Task {
            await store.didFailProvisionalNavigation(error: error)
        }
    }

    public func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: any Error
    ) {
        Task {
            await store.didFail(error: error)
        }
    }
}
