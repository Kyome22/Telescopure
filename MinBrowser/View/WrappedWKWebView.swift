//
//  WrappedWKWebView.swift
//  MinBrowser
//
//  Created by Takuto Nakamura on 2022/04/02.
//

import SwiftUI
import WebKit
import Combine

struct WrappedWKWebView<T: WebViewModelProtocol>: UIViewRepresentable {
    typealias UIViewType = WKWebView

    private let webView: WKWebView
    @ObservedObject var viewModel: T

    init(viewModel: T) {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true

        webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.backgroundColor = UIColor.secondarySystemBackground
        webView.isOpaque = false

        self.viewModel = viewModel
    }

    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        func openURL(urlString: String) {
            if let url = URL(string: urlString) {
                webView.load(URLRequest(url: url))
            }
        }

        switch viewModel.action {
        case .none:
            return
        case .goBack:
            if webView.canGoBack {
                webView.goBack()
            }
        case .goForward:
            if webView.canGoForward {
                webView.goForward()
            }
        case .reload:
            webView.reload()
        case .search(let searchText):
            if searchText.isEmpty {
                openURL(urlString: "https://www.google.com")
            } else if searchText.match(pattern: #"^[a-zA-Z]+://"#) {
                openURL(urlString: searchText)
            } else if let encoded = searchText.percentEncoded {
                let urlString = "https://www.google.com/search?q=\(encoded)"
                openURL(urlString: urlString)
            }
        }
        viewModel.action = .none
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        let contentView: WrappedWKWebView
        var cancellables = Set<AnyCancellable>()

        init(_ contentView: WrappedWKWebView) {
            self.contentView = contentView
            super.init()

            contentView.webView
                .publisher(for: \.estimatedProgress)
                .assign(to: \.estimatedProgress, on: contentView.viewModel)
                .store(in: &cancellables)

            contentView.webView
                .publisher(for: \.isLoading)
                .sink { value in
                    if value {
                        contentView.viewModel.estimatedProgress = 0
                        contentView.viewModel.progressOpacity = 1
                    } else {
                        contentView.viewModel.progressOpacity = 0
                    }
                }
                .store(in: &cancellables)

            contentView.webView
                .publisher(for: \.canGoBack)
                .assign(to: \.canGoBack, on: contentView.viewModel)
                .store(in: &cancellables)

            contentView.webView
                .publisher(for: \.canGoForward)
                .assign(to: \.canGoForward, on: contentView.viewModel)
                .store(in: &cancellables)

            contentView.webView
                .publisher(for: \.title)
                .assign(to: \.title, on: contentView.viewModel)
                .store(in: &cancellables)

            contentView.webView
                .publisher(for: \.url)
                .sink { url in
                    contentView.viewModel.url = url
                    if let url = url {
                        contentView.viewModel.inputText = url.absoluteString
                    }
                }
                .store(in: &cancellables)
        }

        // MARK: - WKNavigationDelegate
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let requestURL = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }

            DebugLog(Coordinator.self, requestURL.absoluteString)

            switch requestURL.scheme {
            case "http", "https", "blob", "file", "about":
                decisionHandler(.allow)
            case "sms", "tel", "facetime", "facetime-audio", "mailto", "imessage":
                UIApplication.shared.open(requestURL, options: [:]) { result in
                    DebugLog(Coordinator.self, "\(result)")
                }
                decisionHandler(.cancel)
            case "minbrowser":
                if let components = URLComponents(url: requestURL, resolvingAgainstBaseURL: false),
                   let queryItem = components.queryItems?.first(where: { $0.name == "url" }),
                   let queryURL = queryItem.value,
                   let url = URL(string: queryURL) {
                    webView.load(URLRequest(url: url))
                }
                decisionHandler(.cancel)
            default:
                UIApplication.shared.open(requestURL, options: [:]) { result in
                    DebugLog(Coordinator.self, "\(result)")
                }
                decisionHandler(.cancel)
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
            contentView.viewModel.showAlert(message: message,
                                            completion: completionHandler)
        }

        // Confirm
        func webView(
            _ webView: WKWebView,
            runJavaScriptConfirmPanelWithMessage message: String,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping (Bool) -> Void
        ) {
            contentView.viewModel.showConfirm(message: message,
                                              completion: completionHandler)
        }

        // Prompt
        func webView(
            _ webView: WKWebView,
            runJavaScriptTextInputPanelWithPrompt prompt: String,
            defaultText: String?,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping (String?) -> Void
        ) {
            contentView.viewModel.showPrompt(prompt: prompt,
                                             defaultText: defaultText,
                                             completion: completionHandler)
        }
    }
}
