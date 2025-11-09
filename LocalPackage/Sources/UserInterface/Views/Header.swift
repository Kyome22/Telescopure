import DataSource
import Model
import SwiftUI

struct Header: View {
    @Environment(\.appDependencies) private var appDependencies
    @Environment(\.isLoading) private var isLoading
    @Environment(\.estimatedProgress) private var estimatedProgress
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
                SearchBar(store: store)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color(.header))
            ProgressView(value: estimatedProgress)
                .opacity(isLoading ? 1.0 : 0.0)
        }
    }
}

#Preview {
    Header(store: .init(.testDependencies()))
}
