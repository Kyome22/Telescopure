//
//  WebViewModelMock.swift
//  MinBrowser
//
//  Created by Takuto Nakamura on 2022/08/12.
//

import Foundation

final class WebViewModelMock: WebViewModelProtocol {
    @Published var action: WebAction = .none
    @Published var estimatedProgress: Double = 0.0
    @Published var progressOpacity: Double = 0.0
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false

    @Published var inputText: String = ""

    @Published var showDialog: Bool = false
    @Published var dialog: WebDialog = .alert
    @Published var dialogMessage: String = ""
    @Published var promptDefaultText: String = ""
    @Published var promptInput: String = ""

    @Published var showBookmark: Bool = false
    @Published var url: URL? = nil
    @Published var title: String? = nil

    @Published var hideToolBar: Bool = false

    func search(with text: String, userDefaults: UserDefaults) { fatalError() }
    func goBack() { fatalError() }
    func goForward() { fatalError() }
    func reload() { fatalError() }

    func showAlert(message: String, completion: @escaping () -> Void) {
        fatalError()
    }
    func showConfirm(message: String, completion: @escaping (Bool) -> Void) {
        fatalError()
    }
    func showPrompt(prompt: String, defaultText: String?, completion: @escaping (String?) -> Void) {
        fatalError()
    }
    func dialogOK() { fatalError() }
    func dialogCancel() { fatalError() }
}
