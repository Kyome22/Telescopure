//
//  WebViewModelMock.swift
//  MinBrowser
//
//  Created by Takuto Nakamura on 2022/08/12.
//

import Foundation
import WebKit

final class WebViewModelMock: WebViewModelProtocol {
    @Published var estimatedProgress: Double = 0.0
    @Published var progressOpacity: Double = 0.0
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var inputText: String = ""
    @Published var showDialog: Bool = false
    @Published var webDialog: WebDialog = .alert("")
    @Published var promptInput: String = ""
    @Published var showBookmark: Bool = false
    @Published var url: URL? = nil
    @Published var title: String? = nil
    @Published var hideToolBar: Bool = false

    func setWebView(_ webView: WKWebView) {}

    func search(with text: String, userDefaults: UserDefaults) {}
    func goBack() {}
    func goForward() {}
    func reload() {}
    func dialogOK() { fatalError() }
    func dialogCancel() { fatalError() }
}
