/*
 BookmarkViewModel.swift
 Telescopure

 Created by Takuto Nakamura on 2023/11/04.
*/

import SwiftUI

protocol BookmarkViewModelProtocol: ObservableObject {
    var bookmarksJSON: String { get set }
    var bookmarks: [Bookmark] { get set }
    var isPresentedEditDialog: Bool { get set }
    var editingTitle: String { get set }
    var editingURL: String { get set }

    var currentTitle: String? { get }
    var currentURL: URL? { get }
    var isDisabledToAdd: Bool { get }
    var isDisabledToEdit: Bool { get }

    init(currentTitle: String?,
         currentURL: URL?,
         loadBookmarkHandler: @escaping (String) -> Void)

    func initializeBookmarks()
    func addBookmark()
    func openEditDialog(_ bookmark: Bookmark)
    func editBookmark()
    func deleteBookmark(_ bookmark: Bookmark)
    func loadBookmark(_ bookmark: Bookmark)
}

final class BookmarkViewModel: BookmarkViewModelProtocol {
    @AppStorage(.bookmarksJSON) var bookmarksJSON = "[]"
    @Published var bookmarks = [Bookmark]()
    @Published var isPresentedEditDialog: Bool = false
    @Published var editingTitle: String = ""
    @Published var editingURL: String = ""

    let currentTitle: String?
    let currentURL: URL?
    private let loadBookmarkHandler: (String) -> Void
    private var editingBookmark: Bookmark?

    var isDisabledToAdd: Bool {
        return currentURL == nil
    }

    var isDisabledToEdit: Bool {
        if editingTitle.isEmpty || editingURL.isEmpty {
            return true
        }
        guard let bookmark = editingBookmark else { return true }
        if editingTitle == bookmark.title && editingURL == bookmark.url {
            return true
        }
        return false
    }

    init(
        currentTitle: String?,
        currentURL: URL?,
        loadBookmarkHandler: @escaping (String) -> Void
    ) {
        self.currentTitle = currentTitle
        self.currentURL = currentURL
        self.loadBookmarkHandler = loadBookmarkHandler
    }

    func initializeBookmarks() {
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

    private func updateBookmarkJSON() {
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

    func addBookmark() {
        if let title = currentTitle, let url = currentURL {
            bookmarks.append(Bookmark(title: title, url: url.absoluteString))
            updateBookmarkJSON()
        }
    }

    func openEditDialog(_ bookmark: Bookmark) {
        editingBookmark = bookmark
        editingTitle = bookmark.title
        editingURL = bookmark.url
        isPresentedEditDialog = true
    }

    func editBookmark() {
        if let bookmark = editingBookmark,
           let index = bookmarks.firstIndex(of: bookmark) {
            editingBookmark = nil
            bookmarks[index] = Bookmark(title: editingTitle,
                                        url: editingURL)
            updateBookmarkJSON()
        }
    }

    func deleteBookmark(_ bookmark: Bookmark) {
        if let index = bookmarks.firstIndex(of: bookmark) {
            bookmarks.remove(at: index)
            updateBookmarkJSON()
        }
    }

    func loadBookmark(_ bookmark: Bookmark) {
        loadBookmarkHandler(bookmark.url)
    }
}

// MARK: Mock
final class BookmarkViewModelMock: BookmarkViewModelProtocol {
    @Published var bookmarksJSON = "[]"
    @Published var bookmarks = [Bookmark]()
    @Published var isPresentedEditDialog: Bool = false
    @Published var editingTitle: String = ""
    @Published var editingURL: String = ""

    var currentTitle: String? = nil
    var currentURL: URL? = nil
    var isDisabledToAdd: Bool = false
    var isDisabledToEdit: Bool = true

    init(currentTitle: String?,
         currentURL: URL?,
         loadBookmarkHandler: @escaping (String) -> Void) {}
    init() {}

    func initializeBookmarks() {}
    func addBookmark() {}
    func openEditDialog(_ bookmark: Bookmark) {}
    func editBookmark() {}
    func deleteBookmark(_ bookmark: Bookmark) {}
    func loadBookmark(_ bookmark: Bookmark) {}
}
