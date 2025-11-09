import SwiftUI

private struct ExternalAppConfirmationDialogModifier: ViewModifier {
    @Binding var isPresented: Bool
    var presenting: URL?
    var okButtonTapped: (URL) async -> Void

    func body(content: Content) -> some View {
        content
            .confirmationDialog(
                Text("openExternalApp", bundle: .module),
                isPresented: $isPresented,
                titleVisibility: .visible,
                presenting: presenting,
                actions: { url in
                    Button {
                        Task {
                            await okButtonTapped(url)
                        }
                    } label: {
                        Text("ok", bundle: .module)
                    }
                },
                message: { url in
                    Text(verbatim: url.absoluteString)
                }
            )
    }
}

extension View {
    func externalAppConfirmationDialog(
        isPresented: Binding<Bool>,
        presenting: URL?,
        okButtonTapped: @escaping (URL) async -> Void
    ) -> some View {
        modifier(ExternalAppConfirmationDialogModifier(
            isPresented: isPresented,
            presenting: presenting,
            okButtonTapped: okButtonTapped
        ))
    }
}
