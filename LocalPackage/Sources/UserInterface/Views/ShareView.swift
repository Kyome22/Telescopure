import DataSource
import Model
import SwiftUI

public struct ShareView: View {
    @StateObject private var store: Share

    public init(store: Share) {
        _store = .init(wrappedValue: store)
    }

    public var body: some View {
        VStack(spacing: 0) {
            Button {
                Task {
                    await store.send(.cancelButtonTapped)
                }
            } label: {
                Text("cancel", bundle: .module)
            }
            .padding(16)
            Color(.systemGray3)
                .frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1)
            Text(verbatim: store.sharedType.sharedText)
                .lineLimit(7)
                .foregroundColor(Color.primary)
                .padding(16)
            Color(.systemGray3)
                .frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1)
            Button {
                Task {
                    await store.send(.openButtonTapped)
                }
            } label: {
                Text(store.sharedType.labelKey)
            }
            .padding(16)
        }
        .background(Color(.systemGray5), in: .rect(cornerRadius: 12))
        .shadow(radius: 8)
        .padding(40)
        .task {
            await store.send(.task)
        }
    }
}
