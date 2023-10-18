/*
 ShareError.swift
 TelescopureShare

 Created by Takuto Nakamura on 2022/12/17.
*/

import Foundation

enum ShareError: LocalizedError {
    case nonAttachmentsItem
    case nonURLItem
    case nonTextItem
    case nonSupportedItem
    case canceled

    var errorDescription: String? {
        switch self {
        case .nonAttachmentsItem:
            return "Non-Attachments item"
        case .nonURLItem:
            return "Non-URL Item"
        case .nonTextItem:
            return "Non-Text Item"
        case .nonSupportedItem:
            return "Non-Supported Item"
        case .canceled:
            return "Canceled"
        }
    }
}
