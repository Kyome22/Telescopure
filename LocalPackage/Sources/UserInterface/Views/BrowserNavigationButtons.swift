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
