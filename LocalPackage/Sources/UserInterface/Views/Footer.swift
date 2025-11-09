import Model
import SwiftUI

struct Footer: View {
    @Environment(\.appDependencies) private var appDependencies
    @Environment(\.canGoBack) private var canGoBack
    @Environment(\.canGoForward) private var canGoForward
    @ScaledMetric private var imageSize = 40
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
                            .imageScale(.large)
                            .frame(width: imageSize, height: imageSize)
                    }
                    .labelStyle(.iconOnly)
                }
                .buttonStyle(.borderless)
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
                            .imageScale(.large)
                            .frame(width: imageSize, height: imageSize)
                    }
                    .labelStyle(.iconOnly)
                }
                .buttonStyle(.borderless)
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
                            .imageScale(.large)
                            .frame(width: imageSize, height: imageSize)
                    }
                    .labelStyle(.iconOnly)
                }
                .buttonStyle(.borderless)
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
                            .imageScale(.large)
                            .frame(width: imageSize, height: imageSize)
                    }
                    .labelStyle(.iconOnly)
                }
                .buttonStyle(.borderless)
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
                            .imageScale(.large)
                            .frame(width: imageSize, height: imageSize)
                    }
                    .labelStyle(.iconOnly)
                }
                .buttonStyle(.borderless)
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
