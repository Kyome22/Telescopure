import Foundation

public enum SharedType: Equatable {
    case undefined
    case link(URL)
    case plainText(String)

    public var sharedText: String {
        switch self {
        case .undefined:
            return "Undefined"
        case let .link(url):
            let urlString = url.absoluteString.removingPercentEncoding ?? url.absoluteString
            return (255 < urlString.count) ? urlString.prefix(255) + "…" : urlString
        case let .plainText(text):
            return (255 < text.count) ? text.prefix(255) + "…" : text
        }
    }

    public var shareURL: URL? {
        switch self {
        case .undefined:
            nil
        case let .link(url):
            // url is already percent-encoded.
            URL(string: "telescopure://?link=\(url.absoluteString)")
        case let .plainText(text):
            URLComponents(string: "telescopure://?plaintext=\(text)")?.url
        }
    }

    public var symbolName: String {
        switch self {
        case .undefined:
            "questionmark.square.dashed"
        case .link:
            "globe"
        case .plainText:
            "text.magnifyingglass"
        }
    }
}
