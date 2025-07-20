import Foundation

public enum SearchEngine: String {
    case google
    case bing
    case duckduckgo

    public var url: String {
        switch self {
        case .google:
            "https://www.google.com"
        case .bing:
            "https://www.bing.com"
        case .duckduckgo:
            "https://duckduckgo.com"
        }
    }

    public func urlWithQuery(keywords: String) -> String {
        switch self {
        case .google:
            "https://www.google.com/search?q=\(keywords)"
        case .bing:
            "https://www.bing.com/search?q=\(keywords)"
        case .duckduckgo:
            "https://duckduckgo.com/?q=\(keywords)"
        }
    }
}
