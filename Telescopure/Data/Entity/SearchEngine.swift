/*
 SearchEngine.swift
 Telescopure

 Created by Takuto Nakamura on 2022/08/14.
*/

import Foundation

enum SearchEngine: String {
    case google
    case bing
    case duckduckgo

    var url: String {
        switch self {
        case .google:     return "https://www.google.com"
        case .bing:       return "https://www.bing.com"
        case .duckduckgo: return "https://duckduckgo.com"
        }
    }

    func urlWithQuery(keywords: String) -> String {
        switch self {
        case .google:     return "https://www.google.com/search?q=\(keywords)"
        case .bing:       return "https://www.bing.com/search?q=\(keywords)"
        case .duckduckgo: return "https://duckduckgo.com/?q=\(keywords)"
        }
    }
}
