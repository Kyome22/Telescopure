import Foundation
import DataSource
import Observation

@MainActor @Observable public final class SearchEngineSetting: Composable {
    private let logService: LogService

    public var selection: SearchEngine
    public let action: (Action) async -> Void

    public init(
        _ appDependencies: AppDependencies,
        selection: SearchEngine,
        action: @escaping (Action) async -> Void
    ) {
        self.logService = .init(appDependencies)
        self.selection = selection
        self.action = action
    }

    public func reduce(_ action: Action) async {
        switch action {
        case let .task(screenName):
            logService.notice(.screenView(name: screenName))

        case .onChangeSearchEngine:
            break
        }
    }

    public enum Action: Sendable {
        case task(String)
        case onChangeSearchEngine(SearchEngine)
    }
}
