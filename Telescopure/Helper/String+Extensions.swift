/*
 String+Extensions.swift
 Telescopure

 Created by Takuto Nakamura on 2022/04/02.
*/

import Foundation

extension String {
    static let bookmarksJSON = "bookmarksJSON"

    func match(pattern: String) -> Bool {
        let matchRange = self.range(of: pattern, options: .regularExpression)
        return matchRange != nil
    }

    var localized: String {
        return NSLocalizedString(self, comment: self)
    }

    var firstCapitalized: String {
        self.components(separatedBy: .whitespaces)
            .enumerated()
            .map { (offset, item) in
                return offset == 0 ? item.capitalized : item
            }
            .joined(separator: " ")
    }
}
