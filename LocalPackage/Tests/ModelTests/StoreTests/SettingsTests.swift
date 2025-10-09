import Foundation
import os
import Testing
import WebKit

@testable import DataSource
@testable import Model

struct SettingsTests {
    @MainActor @Test
    func send_defaultBrowserAppButtonTapped() async {
        let openURLs = OSAllocatedUnfairLock<[URL]>(initialState: [])
        let sut = Settings(
            .testDependencies(
                uiApplicationClient: testDependency(of: UIApplicationClient.self) {
                    $0.settingsURL = { URL(string: "app-settings:default-applications") }
                    $0.open = { url in
                        openURLs.withLock { $0.append(url) }
                        return true
                    }
                }
            ),
            id: UUID(),
            action: { _ in }
        )
        await sut.send(.defaultBrowserAppButtonTapped)
        #expect(openURLs.withLock(\.self) == [URL(string: "app-settings:default-applications")!])
    }

    @MainActor @Test
    func send_crearCacheButtonTapped() async {
        let removedData = OSAllocatedUnfairLock<Set<String>>(initialState: [])
        let sut = Settings(
            .testDependencies(
                wkWebsiteDataStoreClient: testDependency(of: WKWebsiteDataStoreClient.self) {
                    $0.allWebsiteDataTypes = { [WKWebsiteDataTypeCookies] }
                    $0.removeData = { set, _ in
                        removedData.withLock { $0.formUnion(set) }
                    }
                }
            ),
            id: UUID(),
            action: { _ in }
        )
        await sut.send(.crearCacheButtonTapped)
        #expect(removedData.withLock(\.self) == [WKWebsiteDataTypeCookies])
    }

    @MainActor @Test
    func send_openRepositoryButtonTapped() async {
        let openURLs = OSAllocatedUnfairLock<[URL]>(initialState: [])
        let sut = Settings(
            .testDependencies(
                uiApplicationClient: testDependency(of: UIApplicationClient.self) {
                    $0.open = { url in
                        openURLs.withLock { $0.append(url) }
                        return true
                    }
                }
            ),
            id: UUID(),
            action: { _ in }
        )
        await sut.send(.openRepositoryButtonTapped)
        #expect(openURLs.withLock(\.self) == [URL(string: "https://github.com/Kyome22/Telescopure")!])
    }

    @MainActor @Test(arguments: SearchEngine.allCases)
    func send_searchEngineSetting_onChangeSearchEngine(_ searchEngine: SearchEngine) async {
        let setSearchEngine = OSAllocatedUnfairLock<[String?]>(initialState: [])
        let sut = Settings(
            .testDependencies(
                userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                    $0.setString = { value, key in
                        guard key == "search-engine" else { return }
                        setSearchEngine.withLock { $0.append(value) }
                    }
                }
            ),
            id: UUID(),
            action: { _ in }
        )
        await sut.send(.searchEngineSetting(.onChangeSearchEngine(searchEngine)))
        #expect(sut.searchEngine == searchEngine)
        #expect(setSearchEngine.withLock(\.self) == [searchEngine.rawValue])
    }
}
