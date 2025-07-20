import Foundation
import DataSource
import Observation

@MainActor @Observable public final class SearchEngineSetting {
    private let logService: LogService
    private let action: @MainActor (Action) async -> Void

    public var selection: SearchEngine

    public init(
        _ appDependencies: AppDependencies,
        selection: SearchEngine,
        action: @MainActor @escaping (Action) async -> Void
    ) {
        self.selection = selection
        self.logService = .init(appDependencies)
        self.action = action
    }

    public func send(_ action: Action) async {
        await self.action(action)

        switch action {
        case let .task(screenName):
            logService.notice(.screenView(name: screenName))

        case .onChangeSearchEngine:
            break
        }
    }

    public enum Action {
        case task(String)
        case onChangeSearchEngine(SearchEngine)
    }
}
