import Model
import SwiftUI

struct ShowToolBarButton: View {
    @Bindable var store: Browser

    var body: some View {
        Button {
            Task {
                await store.send(.showToolBarButtonTapped)
            }
        } label: {
            Label {
                Text("showToolBar", bundle: .module)
            } icon: {
                Image(systemName: "chevron.up")
                    .imageScale(.large)
                    .frame(width: 40, height: 40)
            }
            .labelStyle(.iconOnly)
        }
        .buttonStyle(.borderless)
        .background(Color(.floating), in: Circle())
        .accessibilityIdentifier("showToolBarButton")
        .shadow(radius: 8)
    }
}

#Preview {
    ShowToolBarButton(store: .init(.testDependencies()))
}
