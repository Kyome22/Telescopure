import Foundation

public struct UUIDClient: DependencyClient {
    public var create: @Sendable () -> UUID

    public static let liveValue = Self(
        create: { UUID() }
    )

    public static let testValue = Self(
        create: { UUID(0) }
    )
}

extension UUID {
    public init(_ intValue: Int) {
        self.init(uuidString: "00000000-0000-0000-0000-\(String(format: "%012x", intValue))")!
    }
}
