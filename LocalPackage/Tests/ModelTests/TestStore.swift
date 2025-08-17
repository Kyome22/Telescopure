import Model
import Foundation
import Observation
import Testing

@MainActor @Observable @dynamicMemberLookup
final class TestStore<Store: Composable>: Composable {
    typealias Action = Store.Action

    private var wrappedStore: Store
    private(set) var actionHistory = [Action]()
    private(set) var wasSentByTestStore = false

    let action: (Store.Action) async -> Void = { _ in }

    init(_ factory: (_ action: @escaping (Action) async -> Void) -> Store) {
        weak var weakSelf: TestStore? = nil
        wrappedStore = factory {
            guard let weakSelf else { return }
            if weakSelf.wasSentByTestStore {
                weakSelf.wasSentByTestStore = false
            } else {
                weakSelf.actionHistory.append($0)
            }
        }
        weakSelf = self
    }

    subscript<T>(dynamicMember keyPath: KeyPath<Store, T>) -> T {
        wrappedStore[keyPath: keyPath]
    }

    subscript<T>(dynamicMember keyPath: WritableKeyPath<Store, T>) -> T {
        get { wrappedStore[keyPath: keyPath] }
        set { wrappedStore[keyPath: keyPath] = newValue }
    }

    func send(_ action: Action) async {
        guard actionHistory.isEmpty else {
            Issue.record("There are actions that are not being handled by receive().")
            return
        }
        wasSentByTestStore = true
        await wrappedStore.send(action)
    }

    func receive(expect: @escaping (Action) -> Bool, timeout: TimeInterval = 1.0) async {
        let startTime = Date()

        while Date.now.timeIntervalSince(startTime) < timeout {
            if let action = actionHistory.first, expect(action) {
                actionHistory.removeFirst()
                return
            }
            try? await Task.sleep(for: .milliseconds(10))
        }

        Issue.record("Expected action doesn't receive.")
    }
}
