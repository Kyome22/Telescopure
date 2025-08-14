import Foundation
import DataSource
import Observation

@MainActor @Observable public final class Licenses: Composable {
    private let logService: LogService

    public let action: (Action) async -> Void

    public init(
        _ appDependencies: AppDependencies,
        action: @escaping (Action) async -> Void =  { _ in }
    ) {
        self.logService = .init(appDependencies)
        self.action = action
    }

    public func reduce(_ action: Action) async {
        switch action {
        case let .task(screenName):
            logService.notice(.screenView(name: screenName))
        }
    }

    public enum Action: Sendable {
        case task(String)
    }
}
