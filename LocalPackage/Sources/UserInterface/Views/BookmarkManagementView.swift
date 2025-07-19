import DataSource
import Model
import SwiftUI

struct BookmarkManagementView: View {
    @Bindable var store: BookmarkManagement

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            ZStack(alignment: .center) {
                Text("bookmark", bundle: .module)
                    .font(.title3)
                HStack {
                    Spacer()
                    Button {
                        Task {
                            await store.send(.closeButtonTapped)
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                    }
                    .accessibilityIdentifier("hideBookmarkButton")
                }
            }
            .padding(16)
            .background(Color(.systemGray6))
            List {
                Section {
                    if store.bookmarkItems.isEmpty {
                        HStack {
                            Label {
                                Text("noBookmark", bundle: .module)
                            } icon: {
                                Image(systemName: "book")
                            }
                            .foregroundColor(.secondary)
                            .disabled(true)
                            Spacer()
                        }
                    } else {
                        ForEach(store.bookmarkItems) { store in
                            BookmarkItemView(store: store)
                        }
                    }
                }
                Section {
                    Button {
                        Task {
                            await store.send(.addBookmarkButtonTapped)
                        }
                    } label: {
                        Label {
                            Text("addBookmark", bundle: .module)
                                .foregroundStyle(store.isDisabledToAdd ? Color.secondary : Color.primary)
                        } icon: {
                            Image(systemName: "plus.app")
                                .foregroundStyle(store.isDisabledToAdd ? Color.secondary : Color.accentColor)
                        }
                    }
                    .buttonStyle(.bookmark)
                    .disabled(store.isDisabledToAdd)
                }
            }
            .listStyle(.insetGrouped)
        }
        .task {
            await store.send(.task(String(describing: Self.self)))
        }
    }
}

#Preview {
    BookmarkManagementView(store: .init(.testDependencies(), action: { _ in }))
}
