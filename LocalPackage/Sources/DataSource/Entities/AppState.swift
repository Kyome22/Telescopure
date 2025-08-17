import Combine
import WebKit

public struct AppState: Sendable {
    public var hasAlreadyBootstrap = false
    public let actionPolicySubject = CurrentValueSubject<WKNavigationActionPolicy, Never>(.cancel)
    public let alertResponseSubject = PassthroughSubject<Void, Never>()
    public let confirmResponseSubject = PassthroughSubject<Bool, Never>()
    public let promptResponseSubject = PassthroughSubject<String?, Never>()
}

extension CurrentValueSubject: @retroactive @unchecked Sendable where Failure == Never, Output : Sendable {}
extension PassthroughSubject: @retroactive @unchecked Sendable where Failure == Never, Output : Sendable {}
extension AsyncPublisher: @retroactive @unchecked Sendable {}
