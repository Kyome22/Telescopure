import Model
import SwiftUI

struct ShowToolBarButton: View {
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
                await store.send(.showToolBarButtonTapped)
            }
        } label: {
            if #available(iOS 26, *) {
                Label {
                    Text("showToolBar", bundle: .module)
                } icon: {
                    Image(systemName: "chevron.up")
                        .imageScale(.large)
                        .frame(width: imageSize, height: imageSize)
                }
                .labelStyle(.iconOnly)
                .padding(8)
            } else {
                Label {
                    Text("showToolBar", bundle: .module)
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
        .accessibilityIdentifier("showToolBarButton")
    }
}

#Preview {
    ShowToolBarButton(store: .init(.testDependencies()))
}
