import Model
import Foundation
import Observation
import Testing

@MainActor @Observable @dynamicMemberLookup
final class TestStore<Store: Composable>: Composable {
    typealias Action = Store.Action

    private var wrappedStore: Store
    private(set) var actionHistory = [Action]()

    let action: (Store.Action) async -> Void = { _ in }

    init(_ factory: (_ action: @escaping (Action) async -> Void) -> Store) {
        weak var weakSelf: TestStore?
        wrappedStore = factory { action in
            weakSelf?.actionHistory.append(action)
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
        await wrappedStore.send(action)
        if !actionHistory.isEmpty {
            actionHistory.removeLast()
        }
    }

    func receive(expect: (Action) -> Bool) {
        guard let index = actionHistory.firstIndex(where: expect) else {
            Issue.record("Expected action was not received.")
            return
        }
        actionHistory.remove(at: index)
    }
}
