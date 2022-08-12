//
//  WebViewModel.swift
//  MinBrowser
//
//  Created by Takuto Nakamura on 2022/08/10.
//

import Foundation

enum WebAction {
    case none
    case goBack
    case goForward
    case reload
    case search(String)
}

enum WebDialog {
    case alert
    case confirm
    case prompt
}
typealias AlertType = WebDialog

protocol WebViewModelProtocol: ObservableObject {
    var action: WebAction { get set }
    var estimatedProgress: Double { get set }
    var progressOpacity: Double { get set }
    var canGoBack: Bool { get set }
    var canGoForward: Bool { get set }

    var showDialog: Bool { get set }
    var dialog: WebDialog { get set }
    var dialogMessage: String { get set }
    var promptDefaultText: String { get set }
    var promptInput: String { get set }

    var showBookmark: Bool { get set }
    var title: String? { get set }
    var url: URL? { get set }

    // MARK: Web Action
    func search(with text: String)
    func goBack()
    func goForward()
    func reload()

    // MARK: JS Alert
    func showAlert(
        message: String,
        completion: @escaping () -> Void
    )

    // MARK: JS Confirm
    func showConfirm(
        message: String,
        completion: @escaping (Bool) -> Void
    )

    // MARK: JS Prompt
    func showPrompt(
        prompt: String,
        defaultText: String?,
        completion: @escaping (String?) -> Void
    )

    func dialogOK()
    func dialogCancel()
}

final class WebViewModel: WebViewModelProtocol {
    @Published var action: WebAction = .none
    @Published var estimatedProgress: Double = 0.0
    @Published var progressOpacity: Double = 1.0
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false

    @Published var showDialog: Bool = false
    @Published var dialog: WebDialog = .alert
    @Published var dialogMessage: String = ""
    @Published var promptDefaultText: String = ""
    @Published var promptInput: String = ""

    @Published var showBookmark: Bool = false
    @Published var title: String? = nil
    @Published var url: URL? = nil

    private var alertHandler: (() -> Void)?
    private var confirmHandler: ((Bool) -> Void)?
    private var promptHandler: ((String?) -> Void)?

    // MARK: Web Action
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
    func showAlert(
        message: String,
        completion: @escaping () -> Void
    ) {
        dialogMessage = message
        alertHandler = completion
        dialog = .alert
        showDialog = true
    }

    // MARK: JS Confirm
    func showConfirm(
        message: String,
        completion: @escaping (Bool) -> Void
    ) {
        dialogMessage = message
        confirmHandler = completion
        dialog = .confirm
        showDialog = true
    }

    // MARK: JS Prompt
    func showPrompt(
        prompt: String,
        defaultText: String?,
        completion: @escaping (String?) -> Void
    ) {
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
            promptHandler?(promptInput)
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
