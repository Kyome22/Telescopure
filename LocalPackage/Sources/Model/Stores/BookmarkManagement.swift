import Foundation
import DataSource
import Observation

@MainActor @Observable public final class BookmarkManagement: Identifiable, Composable {
    private let uuidClient: UUIDClient
    private let userDefaultsRepository: UserDefaultsRepository
    private let logService: LogService

    public let id: UUID
    public let currentURL: URL?
    public let currentTitle: String?
    public var bookmarkItems: [BookmarkItem]
    public let action: (Action) async -> Void

    public var isDisabledToAdd: Bool {
        currentURL == nil
    }

    public init(
        _ appDependencies: AppDependencies,
        id: UUID,
        currentURL: URL? = nil,
        currentTitle: String? = nil,
        isPresentedEditDialog: Bool = false,
        editingBookmarkItemID: BookmarkItem.ID? = nil,
        bookmarkItems: [BookmarkItem] = [],
        action: @escaping (Action) async -> Void
    ) {
        self.uuidClient = appDependencies.uuidClient
        self.userDefaultsRepository = .init(appDependencies.userDefaultsClient)
        self.logService = .init(appDependencies)
        self.id = id
        self.currentURL = currentURL
        self.currentTitle = currentTitle
        self.bookmarkItems = bookmarkItems
        self.action = action
    }

    public func reduce(_ action: Action) async {
        switch action {
        case let .task(screenName):
            logService.notice(.screenView(name: screenName))
            bookmarkItems = userDefaultsRepository.bookmarks.map { bookmark in
                BookmarkItem(
                    id: bookmark.id,
                    url: bookmark.url,
                    title: bookmark.title,
                    action: { [weak self] in
                        await self?.send(.bookmarkItem($0))
                    }
                )
            }

        case .addBookmarkButtonTapped:
            guard let currentURL, let currentTitle else { return }
            bookmarkItems.append(.init(
                id: uuidClient.create(),
                url: currentURL,
                title: currentTitle,
                action: { [weak self] in
                    await self?.send(.bookmarkItem($0))
                }
            ))
            saveCurrentBookmaks()

        case .doneButtonTapped:
            break

        case let .bookmarkItem(.deleteButtonTapped(id)):
            bookmarkItems.removeAll { $0.id == id }
            saveCurrentBookmaks()

        case .bookmarkItem(.onUpdateBookmark):
            saveCurrentBookmaks()

        case .bookmarkItem:
            break
        }
    }

    private func saveCurrentBookmaks() {
        userDefaultsRepository.bookmarks = bookmarkItems.map {
            Bookmark(id: $0.id, title: $0.title, url: $0.url)
        }
    }

    public enum Action: Sendable {
        case task(String)
        case addBookmarkButtonTapped
        case doneButtonTapped
        case bookmarkItem(BookmarkItem.Action)
    }
}
