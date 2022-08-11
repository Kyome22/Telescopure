//
//  WebContentView.swift
//  MinBrowser
//
//  Created by Takuto Nakamura on 2022/04/02.
//

import SwiftUI
import WebKit
import Combine

struct WebContentView: UIViewRepresentable {
    typealias UIViewType = WKWebView

    private let webView: WKWebView
    @ObservedObject var viewModel: WebContentViewModel

    init(viewModel: WebContentViewModel) {
        webView = WKWebView()
        self.viewModel = viewModel
    }

    func makeUIView(context: Context) -> WKWebView {
        webView.uiDelegate = context.coordinator
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.backgroundColor = UIColor.secondarySystemBackground
        webView.isOpaque = false
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
            } else if let encoded = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                let urlString = "https://www.google.com/search?q=\(encoded)"
                openURL(urlString: urlString)
            }
        }
        viewModel.action = .none
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    final class Coordinator: NSObject {
        let contentView: WebContentView
        var cancellables = Set<AnyCancellable>()

        init(_ contentView: WebContentView) {
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
        }
    }
}

// MARK: - WKNavigationDelegate
extension WebContentView.Coordinator: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let requestURL = navigationAction.request.url {
            NSLog("🌟🐤 \(requestURL.path)")
            if requestURL.scheme == "http" || requestURL.scheme == "https" {
                decisionHandler(.allow)
                return
            } else {
//                UIApplication.shared.open(requestURL, options: [:]) { result in
//                    NSLog("🌟🐙 \(result)")
//                }
            }
        }
        decisionHandler(.cancel)
    }
}

// MARK: - WKUIDelegate
extension WebContentView.Coordinator: WKUIDelegate {
    // Alert
    func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping () -> Void
    ) {
        Swift.print("🐸")
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
