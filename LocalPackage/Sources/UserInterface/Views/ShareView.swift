import DataSource
import Model
import SwiftUI

public struct ShareView: View {
    @StateObject private var store: Share

    public init(store: Share) {
        _store = .init(wrappedValue: store)
    }

    public var body: some View {
        VStack(spacing: 16) {
            Button {
                Task {
                    await store.send(.cancelButtonTapped)
                }
            } label: {
                Text("cancel", bundle: .module)
            }
            Color(.systemGray3)
                .frame(height: 1)
                .frame(maxWidth: .infinity)
            Text(store.sharedType.sharedText)
                .lineLimit(7)
                .foregroundColor(Color.primary)
            Color(.systemGray3)
                .frame(height: 1)
                .frame(maxWidth: .infinity)
            Button {
                Task {
                    await store.send(.openButtonTapped)
                }
            } label: {
                Text(store.sharedType.label)
            }
        }
        .padding(16)
        .background(Color(.systemGray5), in: .rect(cornerRadius: 12))
        .compositingGroup()
        .shadow(radius: 8)
        .padding(40)
        .task {
            await store.send(.task)
        }
    }
}

extension Share: ObservableObject {}
