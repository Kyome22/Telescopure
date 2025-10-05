import Foundation

public struct NSExtensionContextClient: DependencyClient {
    public var inputItems: @Sendable (NSExtensionContext?) -> [Any]
    public var completeRequest: @MainActor @Sendable (NSExtensionContext?) -> Void
    public var cancelRequest: @MainActor @Sendable (NSExtensionContext?, any Error) -> Void

    public static let liveValue = Self(
        inputItems: { $0?.inputItems ?? [] },
        completeRequest: { $0?.completeRequest(returningItems: []) },
        cancelRequest: { $0?.cancelRequest(withError: $1) }
    )

    public static let testValue = Self(
        inputItems: { _ in [] },
        completeRequest: { _ in },
        cancelRequest: { _, _ in }
    )
}
