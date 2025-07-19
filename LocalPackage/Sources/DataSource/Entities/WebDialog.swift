public enum WebDialog {
    case alert(_ message: String, _ continuation: CheckedContinuation<Void, Never>)
    case confirm(_ message: String, _ continuation: CheckedContinuation<Bool, Never>)
    case prompt(_ prompt: String, _ defaultText: String, _ continuation: CheckedContinuation<String?, Never>)

    public var needsCancel: Bool {
        switch self {
        case .alert: false
        default: true
        }
    }

    public var message: String {
        switch self {
        case let .alert(message, _): message
        case let .confirm(message, _): message
        case let .prompt(message, _, _): message
        }
    }
}
