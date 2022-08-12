//
//  BookmarkView.swift
//  MinBrowser
//
//  Created by Takuto Nakamura on 2022/08/12.
//

import SwiftUI

struct BookmarkView: View {
    @AppStorage("bookmarksJSON") var bookmarksJSON = "[]"
    @State var bookmarks: [Bookmark] = []

    private let currentTitle: String?
    private let currentURL: URL?
    private let closeBookmarkHandler: () -> Void
    private let loadBookmarkHandler: (String) -> Void

    init(
        currentTitle: String?,
        currentURL: URL?,
        closeBookmarkHandler: @escaping () -> Void,
        loadBookmarkHandler: @escaping (String) -> Void
    ) {
        self.currentTitle = currentTitle
        self.currentURL = currentURL
        self.closeBookmarkHandler = closeBookmarkHandler
        self.loadBookmarkHandler = loadBookmarkHandler
    }

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            header()
            bookmarkList()
        }
        .onAppear {
            if let data = bookmarksJSON.data(using: .utf8),
               let obj = try? JSONSerialization.jsonObject(with: data) as? [[String: String]] {
                bookmarks = obj.compactMap({ dict in
                    if let title = dict["title"], let url = dict["url"] {
                        return Bookmark(title: title, url: url)
                    } else {
                        return nil
                    }
                })
            }
        }
    }

    func header() -> some View {
        ZStack(alignment: .center) {
            Text("bookmark")
                .font(.title3)
            HStack {
                Spacer()
                Button {
                    closeBookmarkHandler()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                }
            }
        }
        .padding(16)
        .background(Color.systemGray6)
    }

    func bookmarkList() -> some View {
        List {
            Section {
                if bookmarks.isEmpty {
                    HStack {
                        Label("noBookmark", systemImage: "book")
                            .foregroundColor(.secondary)
                            .disabled(true)
                        Spacer()
                    }
                } else {
                    ForEach(bookmarks, id: \.title.hashValue) { bookmark in
                        HStack {
                            Label(bookmark.title, systemImage: "book")
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture(perform: {
                            loadBookmarkHandler(bookmark.url)
                        })
                    }
                    .onDelete { indexSet in
                        bookmarks.remove(atOffsets: indexSet)
                        updateBookmarkJSON()
                    }
                }
            }
            Section {
                HStack {
                    Label {
                        Text("addBookmark")
                            .foregroundColor(currentURL == nil ? .secondary : .primary)
                    } icon: {
                        Image(systemName: "plus.app")
                            .foregroundColor(currentURL == nil ? .secondary : .accentColor)
                    }
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture(perform: {
                    addBookmark()
                })
                .disabled(currentURL == nil)
            }
        }
        .listStyle(.insetGrouped)
    }

    func addBookmark() {
        if let title = currentTitle, let url = currentURL {
            bookmarks.append(Bookmark(title: title, url: url.absoluteString))
            updateBookmarkJSON()
        }
    }

    func updateBookmarkJSON() {
        let obj = bookmarks.map { bookmark -> [String: String] in
            return [
                "title": bookmark.title,
                "url": bookmark.url
            ]
        }
        if let data = try? JSONSerialization.data(withJSONObject: obj),
           let str = String(data: data, encoding: .utf8) {
            bookmarksJSON = str
        }
    }
}

struct BookmarkView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkView(currentTitle: nil,
                     currentURL: nil,
                     closeBookmarkHandler: {},
                     loadBookmarkHandler: { _ in })
    }
}
