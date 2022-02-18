//
//  String+Extension.swift
//  MinBrowser
//
//  Created by Takuto Nakamura on 2022/02/17.
//

import Foundation

extension String {

    func match(pattern: String) -> Bool {
        let matchRange = self.range(of: pattern, options: .regularExpression)
        return matchRange != nil
    }

}
