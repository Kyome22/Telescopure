import Observation
import WebKit

@MainActor @Observable public final class BrowserUI {
    private let action: @MainActor (Action) async -> Void

    public init(action: @MainActor @escaping (Action) async -> Void) {
        self.action = action
    }

    public func send(_ action: Action) async {
        await self.action(action)
    }

    public enum Action {
        case runJavaScriptAlertPanelWithMessage(String, CheckedContinuation<Void, Never>)
        case runJavaScriptConfirmPanelWithMessage(String, CheckedContinuation<Bool, Never>)
        case runJavaScriptTextInputPanelWithPrompt(String, String?, CheckedContinuation<String?, Never>)
    }
}

public final class BrowserUIDelegate: NSObject, WKUIDelegate, ObservableObject {
    private var store: BrowserUI

    public init(store: BrowserUI) {
        self.store = store
    }

    // Alert
    public func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo
    ) async {
        await withCheckedContinuation { continuation in
            Task { @MainActor [store] in
             await store.send(.runJavaScriptAlertPanelWithMessage(message, continuation))
            }
        }
    }

    // Confirm
    public func webView(
        _ webView: WKWebView,
        runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo
    ) async -> Bool {
        await withCheckedContinuation { continuation in
            Task { @MainActor [store] in
                await store.send(.runJavaScriptConfirmPanelWithMessage(message, continuation))
            }
        }
    }

    // Prompt
    public func webView(
        _ webView: WKWebView,
        runJavaScriptTextInputPanelWithPrompt prompt: String,
        defaultText: String?,
        initiatedByFrame frame: WKFrameInfo
    ) async -> String? {
        await withCheckedContinuation { continuation in
            Task { @MainActor [store] in
                await store.send(.runJavaScriptTextInputPanelWithPrompt(prompt, defaultText, continuation))
            }
        }
    }
}
