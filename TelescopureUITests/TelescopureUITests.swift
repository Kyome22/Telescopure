import XCTest

final class TelescopureUITests: XCTestCase {
    private let timeout: TimeInterval = 10

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    private func launchApp(additionalArguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["ResetUserDefaults"] + additionalArguments
        app.launch()
        return app
    }

    @MainActor
    private func waitUntilHittable(_ element: XCUIElement) {
        let hittableExpectation = expectation(for: NSPredicate(format: "isHittable == true"), evaluatedWith: element)
        wait(for: [hittableExpectation], timeout: timeout)
    }

    @MainActor
    private func waitUntilValue(of element: XCUIElement, matches predicate: NSPredicate) {
        let valueExpectation = expectation(for: predicate, evaluatedWith: element)
        wait(for: [valueExpectation], timeout: timeout)
    }

    @MainActor
    func testSearchKeyword() {
        let app = launchApp(additionalArguments: ["UseUITestSearchResult"])

        let searchTextField = app.textFields["searchTextField"]
        waitUntilHittable(searchTextField)
        searchTextField.tap()
        searchTextField.typeText("apple\n")

        waitUntilValue(
            of: searchTextField,
            matches: NSPredicate(format: "value BEGINSWITH 'file://' AND value ENDSWITH 'uitest-search-result.html?q=apple'")
        )
    }

    @MainActor
    func testClearTextField() {
        let app = launchApp()

        let searchTextField = app.textFields["searchTextField"]
        waitUntilHittable(searchTextField)
        searchTextField.tap()
        searchTextField.typeText("abcdefghijklmn")

        let clearButton = app.buttons["clearButton"]
        waitUntilHittable(clearButton)
        clearButton.tap()

        waitUntilValue(of: searchTextField, matches: NSPredicate(format: "value == 'Search…'"))
    }

    @MainActor
    func testHideToolbar() {
        let app = launchApp()

        let hideToolbarButton = app.buttons["hideToolbarButton"]
        waitUntilHittable(hideToolbarButton)
        hideToolbarButton.tap()

        let showToolbarButton = app.buttons["showToolbarButton"]
        waitUntilHittable(showToolbarButton)
        showToolbarButton.tap()

        waitUntilHittable(hideToolbarButton)
    }

    @MainActor
    func testOpenBookmark() {
        let app = launchApp()

        let openBookmarksButton = app.buttons["openBookmarksButton"]
        waitUntilHittable(openBookmarksButton)
        openBookmarksButton.tap()

        let doneBookmarksButton = app.buttons["doneBookmarksButton"]
        waitUntilHittable(doneBookmarksButton)
        doneBookmarksButton.tap()

        waitUntilHittable(openBookmarksButton)
    }
}
