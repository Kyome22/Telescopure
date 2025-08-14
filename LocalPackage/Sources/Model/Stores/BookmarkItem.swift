import Foundation
import DataSource
import Observation

@MainActor @Observable public final class BookmarkItem: Identifiable, Composable {
    public let id: UUID
    public var url: URL
    public var title: String
    public var isPresentedEditDialog: Bool
    public var editingTitle: String
    public var editingURLString: String
    public let action: (Action) async -> Void

    public var isDisabledToEdit: Bool {
        editingTitle.isEmpty || editingURLString.isEmpty
    }

    public init(
        id: UUID,
        url: URL,
        title: String,
        isPresentedEditDialog: Bool = false,
        editingTitle: String = "",
        editingURLString: String = "",
        action: @escaping (Action) async -> Void
    ) {
        self.id = id
        self.url = url
        self.title = title
        self.isPresentedEditDialog = isPresentedEditDialog
        self.editingTitle = editingTitle
        self.editingURLString = editingURLString
        self.action = action
    }

    public func reduce(_ action: Action) async {
        switch action {
        case .openBookmarkButtonTapped:
            break

        case .deleteButtonTapped:
            break

        case .editButtonTapped:
            editingTitle = title
            editingURLString = url.absoluteString
            isPresentedEditDialog = true

        case .dialogCancelButtonTapped:
            isPresentedEditDialog = false

        case .dialogOKButtonTapped:
            title = editingTitle
            url = URL(string: editingURLString)!
            isPresentedEditDialog = false
            await send(.onUpdateBookmark)

        case .onUpdateBookmark:
            break
        }
    }

    public enum Action: Sendable {
        case openBookmarkButtonTapped(URL)
        case deleteButtonTapped(BookmarkItem.ID)
        case editButtonTapped
        case dialogCancelButtonTapped
        case dialogOKButtonTapped
        case onUpdateBookmark
    }
}
