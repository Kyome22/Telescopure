import Foundation
import Testing

@testable import DataSource
@testable import Model

struct BookmarkItemTests {
    @MainActor @Test
    func send_editButtonTapped() async {
        let sut = BookmarkItem(
            id: UUID(),
            url: URL(string: "https://example.com")!,
            title: "Example",
            action: { _ in }
        )
        await sut.send(.editButtonTapped)
        #expect(sut.editingTitle == "Example")
        #expect(sut.editingURLString == "https://example.com")
        #expect(sut.isPresentedEditDialog)
    }

    @MainActor @Test
    func send_dialogCancelButtonTapped() async {
        let sut = BookmarkItem(
            id: UUID(),
            url: URL(string: "https://example.com")!,
            title: "Example",
            isPresentedEditDialog: true,
            action: { _ in }
        )
        await sut.send(.dialogCancelButtonTapped)
        #expect(!sut.isPresentedEditDialog)
    }

    @MainActor @Test
    func send_dialogOKButtonTapped() async {
        let sut = TestStore {
            BookmarkItem(
                id: UUID(),
                url: URL(string: "https://example.com")!,
                title: "Example",
                isPresentedEditDialog: true,
                editingTitle: "Test",
                editingURLString: "https://test.com",
                action: $0
            )
        }
        await sut.send(.dialogOKButtonTapped)
        await sut.receive {
            if case .onUpdateBookmark = $0 { true } else { false }
        }
        #expect(sut.title == "Test")
        #expect(sut.url == URL(string: "https://test.com")!)
        #expect(!sut.isPresentedEditDialog)
    }
}
