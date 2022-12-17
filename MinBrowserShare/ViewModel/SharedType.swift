//
//  SharedType.swift
//  MinBrowserShare
//
//  Created by Takuto Nakamura on 2022/12/17.
//

import SwiftUI

enum SharedType {
    case link(URL)
    case plainText(String)

    var sharedText: String {
        switch self {
        case .link(let url):
            let urlString = url.absoluteString.removingPercentEncoding ?? url.absoluteString
            return (255 < urlString.count) ? urlString.prefix(255) + "…" : urlString
        case .plainText(let text):
            return (255 < text.count) ? text.prefix(255) + "…" : text
        }
    }

    var shareURL: URL? {
        switch self {
        case .link(let url):
            // url is already percent-encoded.
            return URL(string: "minbrowser://?link=\(url.absoluteString)")
        case .plainText(let text):
            let urlString = "minbrowser://?plaintext=\(text)"
            return URLComponents(string: urlString)?.url
        }
    }

    var localizedKey: LocalizedStringKey {
        switch self {
        case .link(_): return "open_in"
        case .plainText(_): return "search_in"
        }
    }
}
