import Model
import SwiftUI

struct Footer: View {
    @Environment(\.appDependencies) private var appDependencies
    @Environment(\.canGoBack) private var canGoBack
    @Environment(\.canGoForward) private var canGoForward
    @Bindable var store: Browser

    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .overlay(Color(.border))
            HStack {
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
                .buttonStyle(.toolbar)
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
                .buttonStyle(.toolbar)
                .disabled(!canGoForward)
                .accessibilityIdentifier("goForwardButton")
                Spacer()
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
                .buttonStyle(.toolbar)
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
                .buttonStyle(.toolbar)
                .accessibilityIdentifier("openBookmarksButton")
                Button {
                    Task {
                        await store.send(.hideToolbarButtonTapped)
                    }
                } label: {
                    Label {
                        Text("hideToolbar", bundle: .module)
                    } icon: {
                        Image(systemName: "chevron.down")
                    }
                }
                .buttonStyle(.toolbar)
                .accessibilityIdentifier("hideToolbarButton")
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color(.footer))
        }
    }
}

#Preview {
    Footer(store: .init(.testDependencies()))
}
