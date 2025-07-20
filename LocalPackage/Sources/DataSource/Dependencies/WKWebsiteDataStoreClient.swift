import WebKit

public struct WKWebsiteDataStoreClient: DependencyClient {
    public var allWebsiteDataTypes: @MainActor @Sendable () -> Set<String>
    public var dataRecords: @MainActor @Sendable (Set<String>) async -> [WKWebsiteDataRecord]
    public var removeData: @MainActor @Sendable (Set<String>, [WKWebsiteDataRecord]) async -> Void

    public static let liveValue: Self = {
        let dataStore = { @MainActor @Sendable in WKWebsiteDataStore.default() }

        return Self(
            allWebsiteDataTypes: { WKWebsiteDataStore.allWebsiteDataTypes() },
            dataRecords: { await dataStore().dataRecords(ofTypes: $0) },
            removeData: { await dataStore().removeData(ofTypes: $0, for: $1) }
        )
    }()

    public static let testValue = Self(
        allWebsiteDataTypes: { [] },
        dataRecords: { _ in [] },
        removeData: { _, _ in }
    )
}
