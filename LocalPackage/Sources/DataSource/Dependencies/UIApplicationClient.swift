import UIKit

public struct UIApplicationClient: DependencyClient {
    public var open: @MainActor @Sendable (URL) async -> Bool
    public var perform: @MainActor @Sendable (UIViewController, URL) -> Void

    public static let liveValue = Self(
        open: { await UIApplication.shared.open($0) },
        perform: {
            var responder: UIResponder? = $0
            while responder != nil {
                if let application = responder as? UIApplication {
                    application.open($1)
                    break
                }
                responder = responder?.next
            }
        }
    )

    public static let testValue = Self(
        open: { _ in false },
        perform: { _, _ in }
    )
}
