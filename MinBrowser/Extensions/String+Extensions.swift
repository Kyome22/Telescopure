//
//  String+Extensions.swift
//  MinBrowser
//
//  Created by Takuto Nakamura on 2022/04/02.
//

import Foundation

extension String {
    func match(pattern: String) -> Bool {
        let matchRange = self.range(of: pattern, options: .regularExpression)
        return matchRange != nil
    }

    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
}
