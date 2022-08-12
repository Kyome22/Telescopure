//
//  LegacyAlertModifier.swift
//  MinBrowser
//
//  Created by Takuto Nakamura on 2022/08/12.
//

import SwiftUI

struct LegacyAlertModifier: ViewModifier {
    @State private var alertController: UIAlertController?
    @Binding var isPresented: Bool
    @Binding var alertType: AlertType
    @Binding var title: String
    @Binding var message: String
    @Binding var text: String
    @Binding var placeholder: String
    let okActionHandler: () -> Void
    let cancelActionHandler: () -> Void

    func body(content: Content) -> some View {
        content.onChange(of: isPresented) { newValue in
            if newValue, alertController == nil {
                let alertController = makeAlertController()
                self.alertController = alertController
                guard let scene = UIApplication.shared.connectedScenes.first,
                      let windowScene = scene as? UIWindowScene,
                      let window = windowScene.windows.first
                else { return }
                window.rootViewController?.present(alertController, animated: true)
            } else if !newValue, let alertController = alertController {
                alertController.dismiss(animated: true)
                self.alertController = nil
            }
        }
    }

    private func makeAlertController() -> UIAlertController {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        if alertType == .prompt {
            alertController.addTextField { textField in
                textField.placeholder = placeholder
                textField.text = text
                textField.returnKeyType = .done
            }
        }

        if alertType != .alert {
            let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel) { _ in
                cancelActionHandler()
                dismissAlert()
            }
            alertController.addAction(cancelAction)
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            text = alertController.textFields?.first?.text ?? ""
            okActionHandler()
            dismissAlert()
        }
        alertController.addAction(okAction)
        return alertController
    }

    private func dismissAlert() {
        isPresented = false
        alertController = nil
    }
}
