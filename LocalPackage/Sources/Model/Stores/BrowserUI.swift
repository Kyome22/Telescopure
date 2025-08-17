import DataSource
import Observation
import WebKit

@MainActor @Observable public final class BrowserUI {
    private let appStateClient: AppStateClient
    let action: (Action) async -> Void

    init(
        _ appDependencies: AppDependencies,
        action: @escaping (Action) async -> Void
    ) {
        self.appStateClient = appDependencies.appStateClient
        self.action = action
    }

    func runJavaScriptAlertPanel(with message: String) async {
        await action(.runJavaScriptAlertPanel(message))
        for await _ in appStateClient.withLock(\.alertResponseSubject.values) {
            return
        }
    }

    func runJavaScriptConfirmPanel(with message: String) async -> Bool {
        await action(.runJavaScriptConfirmPanel(message))
        for await value in appStateClient.withLock(\.confirmResponseSubject.values) {
            return value
        }
        return false
    }

    func runJavaScriptTextInputPanel(with prompt: String, defaultText: String?) async -> String? {
        await action(.runJavaScriptTextInputPanel(prompt, defaultText))
        for await value in appStateClient.withLock(\.promptResponseSubject.values) {
            return value
        }
        return nil
    }

    public enum Action: Sendable {
        case runJavaScriptAlertPanel(String)
        case runJavaScriptConfirmPanel(String)
        case runJavaScriptTextInputPanel(String, String?)
    }
}

public final class BrowserUIDelegate: NSObject, WKUIDelegate, ObservableObject {
    private var store: BrowserUI

    init(store: BrowserUI) {
        self.store = store
    }

    // Alert
    public func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo
    ) async {
        await store.runJavaScriptAlertPanel(with: message)
    }

    // Confirm
    public func webView(
        _ webView: WKWebView,
        runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo
    ) async -> Bool {
        return await store.runJavaScriptConfirmPanel(with: message)
    }

    // Prompt
    public func webView(
        _ webView: WKWebView,
        runJavaScriptTextInputPanelWithPrompt prompt: String,
        defaultText: String?,
        initiatedByFrame frame: WKFrameInfo
    ) async -> String? {
        await store.runJavaScriptTextInputPanel(with: prompt, defaultText: defaultText)
    }
}
