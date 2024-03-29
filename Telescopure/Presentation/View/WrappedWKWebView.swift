/*
 WrappedWKWebView.swift
 Telescopure

 Created by Takuto Nakamura on 2022/04/02.
*/

import SwiftUI
import WebKit

struct WrappedWKWebView: UIViewRepresentable {
    typealias UIViewType = WKWebView

    let setWebViewHandler: (WKWebView) -> Void

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.isOpaque = false
        webView.backgroundColor = .clear
        setWebViewHandler(webView)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}
