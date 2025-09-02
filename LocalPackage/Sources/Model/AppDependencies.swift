import DataSource
import SwiftUI

public struct AppDependencies: Sendable {
    public var appStateClient = AppStateClient.liveValue
    public var loggingSystemClient = LoggingSystemClient.liveValue
    public var uiApplicationClient = UIApplicationClient.liveValue
    public var userDefaultsClient = UserDefaultsClient.liveValue
    public var uuidClient = UUIDClient.liveValue
    public var webViewProxyClient = WebViewProxyClient.liveValue
    public var wkWebsiteDataStoreClient = WKWebsiteDataStoreClient.liveValue

    static let shared = AppDependencies()
}

extension EnvironmentValues {
    @Entry public var appDependencies = AppDependencies.shared
}

extension AppDependencies {
    public static func testDependencies(
        appStateClient: AppStateClient = .testValue,
        loggingSystemClient: LoggingSystemClient = .testValue,
        uiApplicationClient: UIApplicationClient = .testValue,
        userDefaultsClient: UserDefaultsClient = .testValue,
        uuidClient: UUIDClient = .testValue,
        webViewProxyClient: WebViewProxyClient = .testValue,
        wkWebsiteDataStoreClient: WKWebsiteDataStoreClient = .testValue
    ) -> AppDependencies {
        AppDependencies(
            appStateClient: appStateClient,
            loggingSystemClient: loggingSystemClient,
            uiApplicationClient: uiApplicationClient,
            userDefaultsClient: userDefaultsClient,
            uuidClient: uuidClient,
            webViewProxyClient: webViewProxyClient,
            wkWebsiteDataStoreClient: wkWebsiteDataStoreClient
        )
    }
}
