//
//  WebContentViewModel.swift
//  MinBrowser
//
//  Created by Takuto Nakamura on 2022/08/10.
//

import Foundation

final class WebContentViewModel: ObservableObject {
    enum Action {
        case none
        case goBack
        case goForward
        case reload
        case search(String)
    }

    enum Dialog {
        case alert
        case confirm
        case prompt
    }

    @Published var action: Action = .none
    @Published var estimatedProgress: Double = 0.0
    @Published var progressOpacity: Double = 1.0
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false

    @Published var showDialog: Bool = false
    @Published var dialog: Dialog = .alert
    @Published var dialogMessage: String = ""
    @Published var promptDefaultText: String = ""
    @Published var promptImput: String = ""

    private var alertHandler: (() -> Void)?
    private var confirmHandler: ((Bool) -> Void)?
    private var promptHandler: ((String?) -> Void)?

    func search(with text: String) {
        action = .search(text)
    }

    func goBack() {
        action = .goBack
    }

    func goForward() {
        action = .goForward
    }

    func reload() {
        action = .reload
    }

    // MARK: JS Alert
    func showAlert(message: String, completion: @escaping () -> Void) {
        dialogMessage = message
        alertHandler = completion
        dialog = .alert
        showDialog = true
    }

    // MARK: JS Confirm
    func showConfirm(message: String, completion: @escaping (Bool) -> Void) {
        dialogMessage = message
        confirmHandler = completion
        dialog = .confirm
        showDialog = true
    }

    // MARK: JS Prompt
    func showPrompt(prompt: String, defaultText: String?, completion: @escaping (String?) -> Void) {
        dialogMessage = prompt
        promptDefaultText = defaultText ?? ""
        promptHandler = completion
        dialog = .prompt
        showDialog = true
    }

    func dialogOK() {
        switch dialog {
        case .alert:
            alertHandler?()
        case .confirm:
            confirmHandler?(true)
        case .prompt:
            promptHandler?(promptImput)
        }
    }

    func dialogCancel() {
        switch dialog {
        case .alert:
            return
        case .confirm:
            confirmHandler?(false)
        case .prompt:
            promptHandler?(nil)
        }
    }
}
