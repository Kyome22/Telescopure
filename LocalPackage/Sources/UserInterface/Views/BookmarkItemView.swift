import DataSource
import Model
import SwiftUI

struct BookmarkItemView: View {
    @State var store: BookmarkItem

    var body: some View {
        Button {
            Task {
                await store.send(.openBookmarkButtonTapped(store.url))
            }
        } label: {
            Label(store.title, systemImage: "book")
        }
        .buttonStyle(.bookmark)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
                Task {
                    await store.send(.deleteButtonTapped(store.id))
                }
            } label: {
                Text("delete", bundle: .module)
            }
            .tint(.red)
            Button {
                Task {
                    await store.send(.editButtonTapped)
                }
            } label: {
                Text("edit", bundle: .module)
            }
            .tint(.green)
        }
        .alert(Text("editBookmark", bundle: .module), isPresented: $store.isPresentedEditDialog) {
            TextField(text: $store.editingTitle) {
                Text("inputTitle", bundle: .module)
            }
            TextField(text: $store.editingURLString) {
                Text("inputURL", bundle: .module)
            }
            Button {
                Task {
                    await store.send(.dialogCancelButtonTapped)
                }
            } label: {
                Text("cancel", bundle: .module)
            }
            Button {
                Task {
                    await store.send(.dialogOKButtonTapped)
                }
            } label: {
                Text("ok", bundle: .module)
            }
            .disabled(store.isDisabledToEdit)
        }
    }
}

#Preview {
    BookmarkItemView(store: .init(
        id: UUID(),
        url: URL(string: "https://example.com")!,
        title: "Example",
        action: { _ in }
    ))
}
