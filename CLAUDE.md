# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Telescopure is a minimal iOS browser app (available on the App Store) built with Swift 6.2 targeting iOS 18+, developed with Xcode 26.2+. It can be set as the default browser and is useful for debugging web applications.

## Build & Test

This is an Xcode project — build and test via Xcode or `xcodebuild`. The test plan is `Telescopure.xctestplan`.

To run unit tests from the command line (ModelTests only, no simulator needed for Swift Testing):
```bash
xcodebuild test -project Telescopure.xcodeproj -testPlan Telescopure.xctestplan -destination 'platform=iOS Simulator,name=iPhone 16'
```

To run a single test file or test function, use Xcode's test navigator or the `xcodebuild` `-only-testing` flag:
```bash
xcodebuild test -project Telescopure.xcodeproj -scheme Telescopure -only-testing ModelTests/BrowserTests/send_onChangeURL -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Architecture

The app follows a three-layer architecture defined in `LocalPackage/` (a local Swift Package):

### Layers (dependency order)

| Layer | Target | Role |
|-------|--------|------|
| `DataSource` | `LocalPackage/Sources/DataSource` | Entities, dependency clients (protocol-like structs with `liveValue`/`testValue`), repositories |
| `Model` | `LocalPackage/Sources/Model` | Business logic stores conforming to `Composable`, services, dependency injection container |
| `UserInterface` | `LocalPackage/Sources/UserInterface` | SwiftUI views and scenes, consumes Model stores |

The main app target `Telescopure/` contains only `TelescopureApp.swift` and assets. `TelescopureShare/` is a Share Extension.

### Key Patterns

**`Composable` protocol** (`Model/Composable.swift`): All stores (`@MainActor @Observable` classes) conform to this protocol. Each store has an `Action` enum, a `reduce(_ action:)` method for state mutations, and an `action` closure for propagating actions up to a parent store. Call `send(_:)` to dispatch — it calls `reduce` then `action`.

**`DependencyClient`** (`DataSource/DependencyClient.swift`): External dependencies (UserDefaults, WKWebView proxy, UIApplication, etc.) are modeled as structs with `liveValue` and `testValue` static properties. This enables easy injection in tests without mocks/protocols.

**`AppDependencies`** (`Model/AppDependencies.swift`): Aggregates all `DependencyClient` instances and is passed via SwiftUI's `@Environment` using `@Entry`. Tests call `AppDependencies.testDependencies(...)` to override specific clients.

**Store hierarchy**: `Browser` is the root store. It owns child stores (`Settings`, `BookmarkManagement`) as optional `@Observable` properties, creating them on demand and setting them to `nil` when dismissed. Child actions are namespaced in the parent's `Action` enum (e.g., `Browser.Action.settings(Settings.Action)`).

**`TestStore`** (`Tests/ModelTests/TestStore.swift`): A test wrapper that tracks dispatched child actions in `actionHistory`. Use `receive(expect:)` to assert expected child actions were emitted.

### External Dependencies

- `WebUI` (cybozu) — `WKWebView` wrapped for SwiftUI via `WebViewProxy`
- `swift-log` (apple) — logging abstraction used in `LogService`
- `LicenseList` (cybozu) — OSS license display in Settings

### Swift Concurrency

All stores run on `@MainActor`. Dependency clients use `OSAllocatedUnfairLock` in tests for thread-safe state capture across actor boundaries. Swift 6 strict concurrency is enabled with the `ExistentialAny` upcoming feature flag.
