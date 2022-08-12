//
//  NewAlertModifier.swift
//  MinBrowser
//
//  Created by Takuto Nakamura on 2022/08/12.
//

import SwiftUI

struct MigratedAlertModifier<T: WebViewModelProtocol>: ViewModifier {
    @ObservedObject var viewModel: T

    func body(content: Content) -> some View {
        if #available(iOS 16, *) {
            content.alert("", isPresented: $viewModel.showDialog, actions: {
                if viewModel.dialog == .prompt {
                    // Prompt is only available on iOS 16 or later.
                    // https://sarunw.com/posts/swiftui-alert-textfield/
                    TextField(viewModel.promptDefaultText, text: $viewModel.promptInput)
                }
                Button("OK") {
                    viewModel.dialogOK()
                }
                if viewModel.dialog != .alert {
                    Button("Cancel", role: .cancel) {
                        viewModel.dialogCancel()
                    }
                }
            }, message: {
                Text(viewModel.dialogMessage)
            })
        } else {
            content.modifier(LegacyAlertModifier(
                isPresented: $viewModel.showDialog,
                alertType: $viewModel.dialog,
                title: .constant(""),
                message: $viewModel.dialogMessage,
                text: $viewModel.promptInput,
                placeholder: $viewModel.promptDefaultText,
                okActionHandler: {
                    viewModel.dialogOK()
                },
                cancelActionHandler: {
                    viewModel.dialogCancel()
                }
            ))
        }
    }
}
