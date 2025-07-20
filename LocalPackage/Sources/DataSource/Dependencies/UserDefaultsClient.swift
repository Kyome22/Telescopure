import Foundation

public struct UserDefaultsClient: DependencyClient {
    var string: @Sendable (String) -> String?
    var setString: @Sendable (String?, String) -> Void
    var data: @Sendable (String) -> Data?
    var setData: @Sendable (Data?, String) -> Void
    var removePersistentDomain: @Sendable (String) -> Void
    var persistentDomain: @Sendable (String) -> [String : Any]?

    public static let liveValue = Self(
        string: { UserDefaults.standard.string(forKey: $0) },
        setString: { UserDefaults.standard.set($0, forKey: $1) },
        data: { UserDefaults.standard.data(forKey: $0) },
        setData: { UserDefaults.standard.set($0, forKey: $1) },
        removePersistentDomain: { UserDefaults.standard.removePersistentDomain(forName: $0) },
        persistentDomain: { UserDefaults.standard.persistentDomain(forName: $0) }
    )

    public static let testValue = Self(
        string: { _ in nil },
        setString: { _, _ in },
        data: { _ in nil },
        setData: { _, _ in },
        removePersistentDomain: { _ in },
        persistentDomain: { _ in nil }
    )
}
