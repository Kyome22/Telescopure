import Model
import SwiftUI

struct ToolBar: View {
    @Environment(\.appDependencies) private var appDependencies
    @Bindable var store: Browser
    var canGoBack: Bool
    var canGoForward: Bool

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
                    Image(systemName: "chevron.backward")
                        .imageScale(.large)
                        .frame(width: 40, height: 40, alignment: .center)
                }
                .disabled(!canGoBack)
                Button {
                    Task {
                        await store.send(.goForwardButtonTapped)
                    }
                } label: {
                    Image(systemName: "chevron.forward")
                        .imageScale(.large)
                        .frame(width: 40, height: 40, alignment: .center)
                }
                .disabled(!canGoForward)
                Spacer()
                Button {
                    Task {
                        await store.send(.bookmarkButtonTapped(appDependencies))
                    }
                } label: {
                    Image(systemName: "book")
                        .imageScale(.large)
                        .frame(width: 40, height: 40, alignment: .center)
                }
                .accessibilityIdentifier("showBookmarkButton")
                Button {
                    Task {
                        await store.send(.hideToolBarButtonTapped)
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .imageScale(.large)
                        .frame(width: 40, height: 40, alignment: .center)
                }
                .accessibilityIdentifier("hideToolBarButton")
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color(.footer))
        }
    }
}

#Preview {
    ToolBar(store: .init(.testDependencies()), canGoBack: false, canGoForward: false)
}
