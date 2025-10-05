import Foundation

public enum ShareError: Equatable, LocalizedError {
    case nonAttachmentsItem
    case nonURLItem
    case nonTextItem
    case nonSupportedItem
    case canceled

    public var errorDescription: String? {
        switch self {
        case .nonAttachmentsItem:
            "Non-Attachments item"
        case .nonURLItem:
            "Non-URL Item"
        case .nonTextItem:
            "Non-Text Item"
        case .nonSupportedItem:
            "Non-Supported Item"
        case .canceled:
            "Canceled"
        }
    }
}
