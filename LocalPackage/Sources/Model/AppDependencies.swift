import DataSource
import SwiftUI

public final class AppDependencies: Sendable {
    public let appStateClient: AppStateClient
    public let loggingSystemClient: LoggingSystemClient
    public let uiApplicationClient: UIApplicationClient
    public let userDefaultsClient: UserDefaultsClient
    public let uuidClient: UUIDClient
    public let webViewProxyClient: WebViewProxyClient
    public let wkWebsiteDataStoreClient: WKWebsiteDataStoreClient

    nonisolated init(
        appStateClient: AppStateClient = .liveValue,
        loggingSystemClient: LoggingSystemClient = .liveValue,
        uiApplicationClient: UIApplicationClient = .liveValue,
        userDefaultsClient: UserDefaultsClient = .liveValue,
        uuidClient: UUIDClient = .liveValue,
        webViewProxyClient: WebViewProxyClient = .liveValue,
        wkWebsiteDataStoreClient: WKWebsiteDataStoreClient = .liveValue
    ) {
        self.appStateClient = appStateClient
        self.loggingSystemClient = loggingSystemClient
        self.uiApplicationClient = uiApplicationClient
        self.userDefaultsClient = userDefaultsClient
        self.uuidClient = uuidClient
        self.webViewProxyClient = webViewProxyClient
        self.wkWebsiteDataStoreClient = wkWebsiteDataStoreClient
    }

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
