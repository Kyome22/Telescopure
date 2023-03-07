/*
  WebDialog.swift
  MinBrowser

  Created by Takuto Nakamura on 2023/03/07.
*/

enum WebDialog {
    case alert(_ message: String)
    case confirm(_ message: String)
    case prompt(_ message: String, _ defaultMessage: String)

    var isAlert: Bool {
        switch self {
        case .alert: return true
        default: return false
        }
    }

    var message: String {
        switch self {
        case .alert(let message):
            return message
        case .confirm(let message):
            return message
        case .prompt(let message, _):
            return message
        }
    }
}
