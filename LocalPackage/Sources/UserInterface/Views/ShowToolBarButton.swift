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
            Image(systemName: "chevron.up")
                .imageScale(.large)
                .frame(width: 40, height: 40, alignment: .center)
        }
        .accessibilityIdentifier("showToolBarButton")
        .background(Color(.floating), in: .circle)
        .shadow(radius: 8)
    }
}

#Preview {
    ShowToolBarButton(store: .init(.testDependencies()))
}
