import Model
import SwiftUI

struct ShowToolbarButton: View {
    @ScaledMetric private var imageSize = 40
    var store: Browser

    var body: some View {
        if #available(iOS 26, *) {
            button
                .glassEffect()
        } else {
            button
                .shadow(radius: 8)
        }
    }

    var button: some View {
        Button {
            Task {
                await store.send(.showToolbarButtonTapped)
            }
        } label: {
            if #available(iOS 26, *) {
                Label {
                    Text("showToolbar", bundle: .module)
                } icon: {
                    Image(systemName: "chevron.up")
                        .imageScale(.large)
                        .frame(width: imageSize, height: imageSize)
                }
                .labelStyle(.iconOnly)
                .padding(8)
            } else {
                Label {
                    Text("showToolbar", bundle: .module)
                } icon: {
                    Image(systemName: "chevron.up")
                        .imageScale(.large)
                        .frame(width: imageSize, height: imageSize)
                }
                .labelStyle(.iconOnly)
                .padding(8)
                .background(Color(.floating))
            }
        }
        .buttonStyle(.borderless)
        .buttonBorderShape(.circle)
        .accessibilityIdentifier("showToolbarButton")
    }
}

#Preview {
    ShowToolbarButton(store: .init(.testDependencies()))
}
