import DataSource
import Model
import SwiftUI

struct Header: View {
    @Environment(\.appDependencies) private var appDependencies
    @Environment(\.isLoading) private var isLoading
    @Environment(\.estimatedProgress) private var estimatedProgress
    @FocusState private var focusedField: FocusedField?
    var store: Browser

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Button {
                    Task {
                        await store.send(.settingsButtonTapped(appDependencies))
                    }
                } label: {
                    Label {
                        Text("openSettings", bundle: .module)
                    } icon: {
                        Image(systemName: "gearshape")
                            .imageScale(.large)
                    }
                    .labelStyle(.iconOnly)
                }
                .buttonStyle(.borderless)
                .tint(Color(.systemGray))
                SearchBar(focusedField: $focusedField, store: store)
                if store.isInputingSearchBar {
                    Button {
                        focusedField = nil
                    } label: {
                        Text("cancel", bundle: .module)
                    }
                    .buttonStyle(.borderless)
                    .transition(.asymmetric(insertion: .push(from: .trailing), removal: .slide))
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color(.header))
            .onChange(of: focusedField) { _, newValue in
                Task {
                    await store.send(.onChangeFocusedField(newValue))
                }
            }
            ProgressView(value: estimatedProgress)
                .opacity(isLoading ? 1.0 : 0.0)
        }
    }
}

#Preview {
    Header(store: .init(.testDependencies()))
}
