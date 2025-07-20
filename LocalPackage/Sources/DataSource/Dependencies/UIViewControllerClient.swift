import UIKit

public struct UIViewControllerClient: DependencyClient {
    public var completeRequest: @MainActor @Sendable (UIViewController) -> Void
    public var cancelRequest: @MainActor @Sendable (UIViewController, any Error) -> Void

    public static let liveValue = Self(
        completeRequest: { $0.extensionContext?.completeRequest(returningItems: []) },
        cancelRequest: { $0.extensionContext?.cancelRequest(withError: $1) }
    )

    public static let testValue = Self(
        completeRequest: { _ in },
        cancelRequest: { _, _ in }
    )
}
