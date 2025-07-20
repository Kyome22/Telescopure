import DataSource
import Model
import SwiftUI

struct BookmarkManagementView: View {
    @Bindable var store: BookmarkManagement

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
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await store.send(.closeButtonTapped)
                        }
                    } label: {
                        Label {
                            Text("close", bundle: .module)
                        } icon: {
                            Image(systemName: "xmark")
                        }
                        .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.borderless)
                    .accessibilityIdentifier("closeBookmarksButton")
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
