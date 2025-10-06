import UIKit

public struct UIApplicationClient: DependencyClient {
    public var open: @MainActor @Sendable (URL) async -> Bool

    public static let liveValue = Self(
        open: { await UIApplication.shared.open($0) }
    )

    public static let testValue = Self(
        open: { _ in false }
    )
}
