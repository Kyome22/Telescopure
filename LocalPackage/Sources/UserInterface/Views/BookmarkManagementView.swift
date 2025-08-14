import DataSource
import Model
import SwiftUI

struct BookmarkManagementView: View {
    var store: BookmarkManagement

    var body: some View {
        NavigationStack {
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
            .navigationTitle(Text("bookmarks", bundle: .module))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await store.send(.doneButtonTapped)
                        }
                    } label: {
                        Text("done", bundle: .module)
                    }
                    .accessibilityIdentifier("doneBookmarksButton")
                }
            }
        }
        .task {
            await store.send(.task(String(describing: Self.self)))
        }
    }
}

#Preview {
    BookmarkManagementView(store: .init(.testDependencies(), id: UUID(), action: { _ in }))
}
