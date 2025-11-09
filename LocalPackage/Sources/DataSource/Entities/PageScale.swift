public enum PageScale: Int, Sendable {
    case scale50
    case scale75
    case scale90
    case scale100
    case scale110
    case scale125
    case scale150
    case scale175
    case scale200
    case scale250
    case scale300

    public var value: Double {
        switch self {
        case .scale50: 0.5
        case .scale75: 0.75
        case .scale90: 0.9
        case .scale100: 1.0
        case .scale110: 1.1
        case .scale125: 1.25
        case .scale150: 1.5
        case .scale175: 1.75
        case .scale200: 2.0
        case .scale250: 2.5
        case .scale300: 3.0
        }
    }
}
