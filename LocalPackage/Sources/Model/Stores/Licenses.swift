import Foundation
import DataSource
import Observation

@MainActor @Observable public final class Licenses {
    private let logService: LogService

    public init(_ appDependencies: AppDependencies) {
        self.logService = .init(appDependencies)
    }

    public func send(_ action: Action) {
        switch action {
        case let .onAppear(screenName):
            logService.notice(.screenView(name: screenName))
        }
    }

    public enum Action {
        case onAppear(String)
    }
}
