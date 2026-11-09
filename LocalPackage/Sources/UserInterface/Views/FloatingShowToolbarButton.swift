import Model
import SwiftUI

struct FloatingShowToolbarButton: View {
    @ScaledMetric private var imageSize = 40
    var store: Browser

    var body: some View {
        if #available(iOS 26, *) {
            Button {
                Task {
                    await store.send(.showToolbarButtonTapped)
                }
            } label: {
                Label {
                    Text("showToolbar", bundle: .module)
                } icon: {
                    Image(systemName: "arrow.down.right.and.arrow.up.left")
                        .imageScale(.large)
                        .frame(width: imageSize, height: imageSize)
                }
                .labelStyle(.iconOnly)
            }
            .buttonStyle(.borderless)
            .buttonBorderShape(.circle)
            .glassEffect()
            .accessibilityIdentifier("showToolbarButton")
        } else {
            Button {
                Task {
                    await store.send(.showToolbarButtonTapped)
                }
            } label: {
                Label {
                    Text("showToolbar", bundle: .module)
                } icon: {
                    Image(systemName: "arrow.down.right.and.arrow.up.left")
                        .imageScale(.large)
                        .frame(width: imageSize, height: imageSize)
                        .background(Color(.floating), in: .circle)
                }
                .labelStyle(.iconOnly)
            }
            .buttonStyle(.borderless)
            .shadow(radius: 8)
            .accessibilityIdentifier("showToolbarButton")
        }
    }
}

#Preview {
    FloatingShowToolbarButton(store: .init(.testDependencies()))
}
