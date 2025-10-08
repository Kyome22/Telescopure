import UIKit

public struct UIApplicationClient: DependencyClient {
    public var open: @MainActor @Sendable (URL) async -> Bool
    public var settingsURL: @Sendable () -> URL?

    public static let liveValue = Self(
        open: { await UIApplication.shared.open($0) },
        settingsURL: {
            let urlString = if #available(iOS 18.3, *) {
                UIApplication.openDefaultApplicationsSettingsURLString
            } else {
                UIApplication.openSettingsURLString
            }
            return URL(string: urlString)
        }
    )

    public static let testValue = Self(
        open: { _ in false },
        settingsURL: { nil }
    )
}
