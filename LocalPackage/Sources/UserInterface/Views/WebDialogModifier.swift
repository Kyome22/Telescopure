import DataSource
import SwiftUI

private struct WebDialogModifier: ViewModifier {
    @Binding var isPresented: Bool
    var presenting: WebDialog?
    @Binding var promptInput: String
    var okButtonTapped: () async -> Void
    var cancelButtonTapped: () async -> Void
    var onChangeIsPresented: (Bool) async -> Void

    func body(content: Content) -> some View {
        content
            .alert(
                Text(verbatim: ""),
                isPresented: $isPresented,
                presenting: presenting,
                actions: { webDialog in
                    if case let .prompt(_, defaultText) = webDialog {
                        TextField(defaultText, text: $promptInput)
                    }
                    Button {
                        Task {
                            await okButtonTapped()
                        }
                    } label: {
                        Text("ok", bundle: .module)
                    }
                    if webDialog.needsCancel {
                        Button(role: .cancel) {
                            Task {
                                await cancelButtonTapped()
                            }
                        } label: {
                            Text("cancel", bundle: .module)
                        }
                    }
                },
                message: { webDialog in
                    Text(webDialog.message)
                }
            )
            .onChange(of: isPresented) { _, newValue in
                Task {
                    await onChangeIsPresented(newValue)
                }
            }
    }
}

extension View {
    func webDialog(
        isPresented: Binding<Bool>,
        presenting: WebDialog?,
        promptInput: Binding<String>,
        okButtonTapped: @escaping () async -> Void,
        cancelButtonTapped: @escaping () async -> Void,
        onChangeIsPresented: @escaping (Bool) async -> Void
    ) -> some View {
        modifier(WebDialogModifier(
            isPresented: isPresented,
            presenting: presenting,
            promptInput: promptInput,
            okButtonTapped: okButtonTapped,
            cancelButtonTapped: cancelButtonTapped,
            onChangeIsPresented: onChangeIsPresented
        ))
    }
}
