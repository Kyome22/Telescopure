import Model
import SwiftUI

struct ToolBar: View {
    @Environment(\.appDependencies) private var appDependencies
    @Environment(\.canGoBack) private var canGoBack
    @Environment(\.canGoForward) private var canGoForward
    @ScaledMetric private var imageSize = 40
    var store: Browser

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
                        await store.send(.hideToolBarButtonTapped)
                    }
                } label: {
                    Label {
                        Text("hideToolBar", bundle: .module)
                    } icon: {
                        Image(systemName: "chevron.down")
                            .imageScale(.large)
                            .frame(width: imageSize, height: imageSize)
                    }
                    .labelStyle(.iconOnly)
                }
                .buttonStyle(.borderless)
                .accessibilityIdentifier("hideToolBarButton")
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color(.footer))
        }
    }
}

#Preview {
    ToolBar(store: .init(.testDependencies()))
}
