import Model
import SwiftUI

struct BrowserNavigationButtons: View {
    @Environment(\.canGoBack) private var canGoBack
    @Environment(\.canGoForward) private var canGoForward
    var store: Browser

    var body: some View {
        Button {
            Task {
                await store.send(.goBackButtonTapped)
            }
        } label: {
            Label {
                Text("goBack", bundle: .module)
            } icon: {
                Image(systemName: "chevron.backward")
            }
        }
        .disabled(!canGoBack)
        .accessibilityIdentifier("goBackButton")
        Button {
            Task {
                await store.send(.goForwardButtonTapped)
            }
        } label: {
            Label {
                Text("goForward", bundle: .module)
            } icon: {
                Image(systemName: "chevron.forward")
            }
        }
        .disabled(!canGoForward)
        .accessibilityIdentifier("goForwardButton")
    }
}

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
