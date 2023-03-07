/*
  NewAlertModifier.swift
  MinBrowser

  Created by Takuto Nakamura on 2022/08/12.
*/

import SwiftUI

struct MigratedAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var webDialog: WebDialog
    @Binding var text: String
    let okActionHandler: () -> Void
    let cancelActionHandler: () -> Void

    func body(content: Content) -> some View {
        if #available(iOS 16, *) {
            content.alert("", isPresented: $isPresented, actions: {
                if case .prompt(_, let defaultText) = webDialog {
                    // Prompt is only available on iOS 16 or later.
                    // https://sarunw.com/posts/swiftui-alert-textfield/
                    TextField(defaultText, text: $text)
                }
                Button("OK") {
                    okActionHandler()
                }
                if !webDialog.isAlert {
                    Button("cancel", role: .cancel) {
                        cancelActionHandler()
                    }
                }
            }, message: {
                Text(webDialog.message)
            })
        } else {
            content.modifier(LegacyAlertModifier(
                isPresented: $isPresented,
                webDialog: $webDialog,
                text: $text,
                okActionHandler: {
                    okActionHandler()
                },
                cancelActionHandler: {
                    cancelActionHandler()
                }
            ))
        }
    }
}
