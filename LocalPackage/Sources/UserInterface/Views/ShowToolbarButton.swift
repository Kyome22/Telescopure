import Model
import SwiftUI

struct ShowToolbarButton: View {
    var store: Browser

    var body: some View {
        Button {
            Task {
                await store.send(.showToolbarButtonTapped)
            }
        } label: {
            Label {
                Text("showToolbar", bundle: .module)
            } icon: {
                Image(systemName: "arrow.down.right.and.arrow.up.left")
            }
        }
        .accessibilityIdentifier("showToolbarButton")
    }
}
