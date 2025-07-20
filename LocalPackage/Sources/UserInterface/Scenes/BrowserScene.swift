import Model
import SwiftUI

public struct BrowserScene: Scene {
    @Environment(\.appDependencies) private var appDependencies

    public init() {}

    public var body: some Scene {
        WindowGroup {
            BrowserView(store: .init(appDependencies))
        }
    }
}
