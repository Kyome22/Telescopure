/*
 BookmarkView.swift
 Telescopure

 Created by Takuto Nakamura on 2022/08/12.
*/

import SwiftUI

struct BookmarkView<B: BookmarkViewModelProtocol>: View {
    @StateObject var viewModel: B
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            header
            bookmarkList
        }
        .onAppear {
            viewModel.initializeBookmarks()
        }
        .alert("editBookmark", isPresented: $viewModel.isPresentedEditDialog) {
            TextField("inputTitle", text: $viewModel.editingTitle)
            TextField("inputURL", text: $viewModel.editingURL)
            Button("cancel", role: .cancel) {
                viewModel.isPresentedEditDialog = false
            }
            Button("ok") {
                viewModel.editBookmark()
            }
            // This is a bug in iOS, and if you use it, Action will not fire.
            // .disabled(viewModel.isDisabledToEdit)
        }
    }

    var header: some View {
        ZStack(alignment: .center) {
            Text("bookmark")
                .font(.title3)
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                }
                .accessibilityIdentifier("hideBookmarkButton")
            }
        }
        .padding(16)
        .background(Color.systemGray6)
    }

    var bookmarkList: some View {
        List {
            Section {
                if viewModel.bookmarks.isEmpty {
                    HStack {
                        Label("noBookmark", systemImage: "book")
                            .foregroundColor(.secondary)
                            .disabled(true)
                        Spacer()
                    }
                } else {
                    ForEach(viewModel.bookmarks) { bookmark in
                        bookmarkItem(bookmark)
                    }
                }
            }
            Section {
                Button {
                    viewModel.addBookmark()
                } label: {
                    Label {
                        Text("addBookmark")
                            .foregroundColor(viewModel.isDisabledToAdd ? .secondary : .primary)
                    } icon: {
                        Image(systemName: "plus.app")
                            .foregroundColor(viewModel.isDisabledToAdd ? .secondary : .accentColor)
                    }
                }
                .buttonStyle(.bookmark)
                .disabled(viewModel.isDisabledToAdd)
            }
        }
        .listStyle(.insetGrouped)
    }

    func bookmarkItem(_ bookmark: Bookmark) -> some View {
        return Button {
            viewModel.loadBookmark(bookmark)
            dismiss()
        } label: {
            Label(bookmark.title, systemImage: "book")
        }
        .buttonStyle(.bookmark)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
                viewModel.deleteBookmark(bookmark)
            } label: {
                Text("delete")
            }
            .tint(.red)
            Button {
                viewModel.openEditDialog(bookmark)
            } label: {
                Text("edit")
            }
            .tint(.green)
        }
    }
}

#Preview {
    BookmarkView(viewModel: BookmarkViewModelMock())
}
