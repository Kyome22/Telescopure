import DataSource
import SwiftUI

public final class AppDependencies: Sendable {
    public let appStateClient: AppStateClient
    public let loggingSystemClient: LoggingSystemClient
    public let uiApplicationClient: UIApplicationClient
    public let userDefaultsClient: UserDefaultsClient
    public let webViewProxyClient: WebViewProxyClient

    public nonisolated init(
        appStateClient: AppStateClient = .liveValue,
        loggingSystemClient: LoggingSystemClient = .liveValue,
        uiApplicationClient: UIApplicationClient = .liveValue,
        userDefaultsClient: UserDefaultsClient = .liveValue,
        webViewProxyClient: WebViewProxyClient = .liveValue
    ) {
        self.appStateClient = appStateClient
        self.loggingSystemClient = loggingSystemClient
        self.uiApplicationClient = uiApplicationClient
        self.userDefaultsClient = userDefaultsClient
        self.webViewProxyClient = webViewProxyClient
    }
}

struct AppDependenciesKey: EnvironmentKey {
    static let defaultValue = AppDependencies()
}

public extension EnvironmentValues {
    var appDependencies: AppDependencies {
        get { self[AppDependenciesKey.self] }
        set { self[AppDependenciesKey.self] = newValue }
    }
}

extension AppDependencies {
    public static func testDependencies(
        appStateClient: AppStateClient = .testValue,
        loggingSystemClient: LoggingSystemClient = .testValue,
        uiApplicationClient: UIApplicationClient = .testValue,
        userDefaultsClient: UserDefaultsClient = .testValue,
        webViewProxyClient: WebViewProxyClient = .testValue
    ) -> AppDependencies {
        AppDependencies(
            appStateClient: appStateClient,
            loggingSystemClient: loggingSystemClient,
            uiApplicationClient: uiApplicationClient,
            userDefaultsClient: userDefaultsClient,
            webViewProxyClient: webViewProxyClient
        )
    }
}
