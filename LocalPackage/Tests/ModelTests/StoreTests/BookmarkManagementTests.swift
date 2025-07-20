import Foundation
import os
import Testing

@testable import DataSource
@testable import Model

struct BookmarkManagementTests {
    @MainActor @Test
    func send_task() async {
        let sut = BookmarkManagement(
            .testDependencies(
                userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                    $0.data = { key in
                        guard key == "bookmarks" else { return nil }
                        return try? JSONEncoder().encode([
                            Bookmark(id: UUID(0), title: "title0", url: URL(string: "https://0.com")!),
                            Bookmark(id: UUID(1), title: "title1", url: URL(string: "https://1.com")!),
                        ])
                    }
                },
            ),
            id: UUID(),
            action: { _ in }
        )
        await sut.send(.task(""))
        #expect(sut.bookmarkItems.map(\.id) == [UUID(0), UUID(1)])
        #expect(sut.bookmarkItems.map(\.title) == ["title0", "title1"])
        #expect(sut.bookmarkItems.map(\.url.absoluteString) == ["https://0.com", "https://1.com"])
    }

    @MainActor @Test
    func send_addBookmarkButtonTapped() async {
        let bookmarks = OSAllocatedUnfairLock<[Bookmark]>(initialState: [])
        let sut = BookmarkManagement(
            .testDependencies(
                userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                    $0.setData = { data, key in
                        guard key == "bookmarks",
                              let data,
                              let value = try? JSONDecoder().decode([Bookmark].self, from: data) else {
                            return
                        }
                        bookmarks.withLock { $0 = value }
                    }
                },
                uuidClient: testDependency(of: UUIDClient.self) {
                    $0.create = { UUID(0) }
                }
            ),
            id: UUID(),
            currentURL: URL(string: "https://0.com")!,
            currentTitle: "title0",
            action: { _ in }
        )
        await sut.send(.addBookmarkButtonTapped)
        #expect(bookmarks.withLock(\.self) == [
            Bookmark(id: UUID(0), title: "title0", url: URL(string: "https://0.com")!)
        ])
    }

    @MainActor @Test
    func send_bookmarkItem_deleteButtonTapped() async {
        let bookmarks = OSAllocatedUnfairLock<[Bookmark]>(initialState: [
            Bookmark(id: UUID(0), title: "title0", url: URL(string: "https://0.com")!)
        ])
        let sut = BookmarkManagement(
            .testDependencies(
                userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                    $0.setData = { data, key in
                        guard key == "bookmarks",
                              let data,
                              let value = try? JSONDecoder().decode([Bookmark].self, from: data) else {
                            return
                        }
                        bookmarks.withLock { $0 = value }
                    }
                }
            ),
            id: UUID(),
            bookmarkItems: bookmarks.withLock(\.self).map {
                BookmarkItem(id: $0.id, url: $0.url, title: $0.title, action: { _ in })
            },
            action: { _ in }
        )
        await sut.send(.bookmarkItem(.deleteButtonTapped(UUID(0))))
        #expect(bookmarks.withLock(\.self).isEmpty)
    }

    @MainActor @Test
    func send_bookmarkItem_onUpdateBookmark() async {
        let setDataCount = OSAllocatedUnfairLock(initialState: 0)
        let sut = BookmarkManagement(
            .testDependencies(
                userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                    $0.setData = { data, key in
                        guard key == "bookmarks" else { return }
                        setDataCount.withLock { $0 += 1 }
                    }
                }
            ),
            id: UUID(),
            action: { _ in }
        )
        await sut.send(.bookmarkItem(.onUpdateBookmark))
        #expect(setDataCount.withLock(\.self) == 1)
    }
}
