public enum WebDialog: Sendable, Equatable {
    case alert(_ message: String)
    case confirm(_ message: String)
    case prompt(_ prompt: String, _ defaultText: String)

    public var needsCancel: Bool {
        switch self {
        case .alert: false
        default: true
        }
    }

    public var message: String {
        switch self {
        case let .alert(message): message
        case let .confirm(message): message
        case let .prompt(message, _): message
        }
    }
}
