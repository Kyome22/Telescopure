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
            ZStack(alignment: .center) {
                Text("Bookmark")
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
            .background(Color(UIColor.secondarySystemBackground))
            List {
                Section {
                    if bookmarks.isEmpty {
                        HStack {
                            Label("No Bookmark", systemImage: "book")
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
                        Label("Add", systemImage: "plus.app")
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
