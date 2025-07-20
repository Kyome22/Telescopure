import Foundation

public struct UserDefaultsRepository: Sendable {
    private var userDefaultsClient: UserDefaultsClient

    public var searchEngine: SearchEngine? {
        get {
            guard let value = userDefaultsClient.string(.searchEngine) else { return nil }
            return SearchEngine(rawValue: value)
        }
        nonmutating set {
            userDefaultsClient.setString(newValue?.rawValue, .searchEngine)
        }
    }

    public var bookmarks: [Bookmark] {
        get {
            guard let data = userDefaultsClient.data(.bookmarks) else { return [] }
            return (try? JSONDecoder().decode([Bookmark].self, from: data)) ?? []
        }
        nonmutating set {
            let data = try? JSONEncoder().encode(newValue)
            userDefaultsClient.setData(data, .bookmarks)
        }
    }

    public init(_ userDefaultsClient: UserDefaultsClient) {
        self.userDefaultsClient = userDefaultsClient

#if DEBUG
        if ProcessInfo.needsResetUserDefaults {
            userDefaultsClient.removePersistentDomain(Bundle.main.bundleIdentifier!)
        }
        showAllData()
#endif
    }

    private func showAllData() {
        guard let dict = userDefaultsClient.persistentDomain(Bundle.main.bundleIdentifier!) else {
            return
        }
        for (key, value) in dict.sorted(by: { $0.0 < $1.0 }) {
            Swift.print("\(key) => \(value)")
        }
    }
}
