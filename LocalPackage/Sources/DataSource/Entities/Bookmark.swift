import Foundation

public struct Bookmark: Equatable, Identifiable, Codable, Sendable {
    public var id: UUID
    public var title: String
    public var url: URL

    public init(id: UUID, title: String, url: URL) {
        self.id = id
        self.title = title
        self.url = url
    }
}
