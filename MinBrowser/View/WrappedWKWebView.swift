//
//  WrappedWKWebView.swift
//  MinBrowser
//
//  Created by Takuto Nakamura on 2022/04/02.
//

import SwiftUI
import WebKit
import Combine

struct WrappedWKWebView: UIViewRepresentable {
    typealias UIViewType = WKWebView

    let setWebViewHandler: (WKWebView) -> Void
    let showAlertHandler: (String, @escaping () -> Void) -> Void
    let showConfirmHandler: (String, @escaping (Bool) -> Void) -> Void
    let showPromptHandler: (String, String?, @escaping (String?) -> Void) -> Void

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        setWebViewHandler(webView)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        let contentView: WrappedWKWebView

        init(_ contentView: WrappedWKWebView) {
            self.contentView = contentView
            super.init()
        }
        // MARK: - WKNavigationDelegate
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            preferences: WKWebpagePreferences
        ) async -> (WKNavigationActionPolicy, WKWebpagePreferences) {
            preferences.preferredContentMode = .mobile
            return (WKNavigationActionPolicy.allow, preferences)
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction
        ) async -> WKNavigationActionPolicy {
            guard let requestURL = navigationAction.request.url else {
                return .cancel
            }

            DebugLog(Coordinator.self, requestURL.absoluteString)

            switch requestURL.scheme {
            case "http", "https", "blob", "file", "about":
                return .allow
            case "sms", "tel", "facetime", "facetime-audio", "mailto", "imessage":
                await UIApplication.shared.open(requestURL, options: [:]) { result in
                    DebugLog(Coordinator.self, "\(result)")
                }
                return .cancel
            case "minbrowser":
                if let components = URLComponents(url: requestURL, resolvingAgainstBaseURL: false),
                   let queryItem = components.queryItems?.first(where: { $0.name == "url" }),
                   let queryURL = queryItem.value,
                   let url = URL(string: queryURL) {
                    await webView.load(URLRequest(url: url))
                }
                return .cancel
            default:
                await UIApplication.shared.open(requestURL, options: [:]) { result in
                    DebugLog(Coordinator.self, "\(result)")
                }
                return .cancel
            }
        }

        // MARK: - WKUIDelegate
        // Alert
        func webView(
            _ webView: WKWebView,
            runJavaScriptAlertPanelWithMessage message: String,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping () -> Void
        ) {
            contentView.showAlertHandler(message, completionHandler)
        }

        // Confirm
        func webView(
            _ webView: WKWebView,
            runJavaScriptConfirmPanelWithMessage message: String,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping (Bool) -> Void
        ) {
            contentView.showConfirmHandler(message, completionHandler)
        }

        // Prompt
        func webView(
            _ webView: WKWebView,
            runJavaScriptTextInputPanelWithPrompt prompt: String,
            defaultText: String?,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping (String?) -> Void
        ) {
            contentView.showPromptHandler(prompt, defaultText, completionHandler)
        }
    }
}
