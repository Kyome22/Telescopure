import Foundation

extension ProcessInfo {
    static var needsResetUserDefaults: Bool {
        Self.processInfo.arguments.contains("ResetUserDefaults")
    }

    public static var usesUITestSearchResult: Bool {
        Self.processInfo.arguments.contains("UseUITestSearchResult")
    }
}
