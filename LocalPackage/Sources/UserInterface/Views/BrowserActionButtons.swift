import Model
import SwiftUI

struct BrowserActionButtons: View {
    @Environment(\.appDependencies) private var appDependencies
    @Bindable var store: Browser

    var body: some View {
        Button {
            Task {
                await store.send(.showZoomPopoverButtonTapped)
            }
        } label: {
            Label {
                Text("pageZoom", bundle: .module)
            } icon: {
                Image(systemName: "textformat.size")
            }
        }
        .accessibilityIdentifier("pageZoomButton")
        .popover(isPresented: $store.isPresentedZoomPopover) {
            PageZoomControlPanel(pageScale: store.pageScale) {
                await store.send(.zoomButtonTapped($0))
            }
            .presentationCompactAdaptation(.popover)
        }
        Button {
            Task {
                await store.send(.bookmarkButtonTapped(appDependencies))
            }
        } label: {
            Label {
                Text("openBookmarks", bundle: .module)
            } icon: {
                Image(systemName: "book")
            }
        }
        .accessibilityIdentifier("openBookmarksButton")
        Button {
            Task {
                await store.send(.hideToolbarButtonTapped)
            }
        } label: {
            Label {
                Text("hideToolbar", bundle: .module)
            } icon: {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
            }
        }
        .accessibilityIdentifier("hideToolbarButton")
    }
}
