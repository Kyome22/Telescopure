import Foundation
import DataSource
import Observation

@MainActor @Observable public final class Settings: Identifiable {
    private let uiApplicationClient: UIApplicationClient
    private let wkWebsiteDataStoreClient: WKWebsiteDataStoreClient
    private let userDefaultsRepository: UserDefaultsRepository
    private let logService: LogService
    private let action: @MainActor (Action) async -> Void

    public let id: UUID
    public var path: [Path]
    public var searchEngine: SearchEngine
    public var version: String
    public let developer = "Takuto Nakamura"

    public init(
        _ appDependencies: AppDependencies,
        id: UUID,
        path: [Path] = [],
        searchEngine: SearchEngine? = nil,
        version: String? = nil,
        action: @MainActor @escaping (Action) async -> Void
    ) {
        self.id = id
        self.path = path
        self.uiApplicationClient = appDependencies.uiApplicationClient
        self.wkWebsiteDataStoreClient = appDependencies.wkWebsiteDataStoreClient
        self.userDefaultsRepository = .init(appDependencies.userDefaultsClient)
        self.logService = .init(appDependencies)
        self.action = action
        self.searchEngine = if let searchEngine {
            searchEngine
        } else if let searchEngine = userDefaultsRepository.searchEngine {
            searchEngine
        } else {
            .google
        }
        self.version = version ?? Bundle.main.bundleVersion
    }

    public func send(_ action: Action) async {
        await self.action(action)

        switch action {
        case let .task(screenName):
            logService.notice(.screenView(name: screenName))

        case let .searchEngineSettingButtonTapped(appDependencies):
            path.append(.searchEngineSetting(.init(
                appDependencies,
                selection: searchEngine,
                action: { [weak self] in
                    await self?.send(.searchEngineSetting($0))
                }
            )))

        case .crearCacheButtonTapped:
            let dataTypes = wkWebsiteDataStoreClient.allWebsiteDataTypes()
            let records = await wkWebsiteDataStoreClient.dataRecords(dataTypes)
            await wkWebsiteDataStoreClient.removeData(dataTypes, records)

        case .openRepositoryButtonTapped:
            guard let url = URL(string: "https://github.com/Kyome22/Telescopure") else { return }
            _ = await uiApplicationClient.open(url)

        case let .licensesButtonTapped(appDependencies):
            path.append(.licenses(.init(appDependencies)))

        case .closeButtonTapped:
            break

        case let .searchEngineSetting(.onChangeSearchEngine(searchEngine)):
            self.searchEngine = searchEngine
            userDefaultsRepository.searchEngine = searchEngine

        case .searchEngineSetting:
            break
        }
    }

    public enum Action {
        case task(String)
        case searchEngineSettingButtonTapped(AppDependencies)
        case crearCacheButtonTapped
        case openRepositoryButtonTapped
        case licensesButtonTapped(AppDependencies)
        case closeButtonTapped
        case searchEngineSetting(SearchEngineSetting.Action)
    }

    public enum Path: Hashable {
        case searchEngineSetting(SearchEngineSetting)
        case licenses(Licenses)

        public static func ==(lhs: Path, rhs: Path) -> Bool {
            lhs.id == rhs.id
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        var id: Int {
            switch self {
            case let .searchEngineSetting(value):
                Int(bitPattern: ObjectIdentifier(value))
            case let .licenses(value):
                Int(bitPattern: ObjectIdentifier(value))
            }
        }
    }
}
