import XCTest

final class TelescopureUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testSearchKeyword() {
        let app = XCUIApplication()
        app.launchArguments = ["ResetUserDefaults", "UseUITestSearchResult"]
        app.launch()

        let searchTextField = app.textFields["searchTextField"]
        searchTextField.tap()
        searchTextField.typeText("apple\n")

        let searchedURLPredicate = NSPredicate(format: "value BEGINSWITH 'file://' AND value ENDSWITH 'uitest-search-result.html?q=apple'")
        let searchedURLExpectation = expectation(for: searchedURLPredicate, evaluatedWith: searchTextField)
        wait(for: [searchedURLExpectation], timeout: 10)
    }

    @MainActor
    func testClearTextField() throws {
        let app = XCUIApplication()
        app.launch()

        let searchTextField = app.textFields["searchTextField"]
        searchTextField.tap()
        searchTextField.typeText("abcdefghijklmn")

        let clearButton = app.buttons["clearButton"]
        clearButton.tap()

        let actual = try XCTUnwrap(searchTextField.value as? String)
        let expect = "Search…"
        XCTAssertEqual(actual, expect)
    }

    @MainActor
    func testHideToolbar() {
        let app = XCUIApplication()
        app.launch()

        let hideToolbarButton = app.buttons["hideToolbarButton"]
        hideToolbarButton.tap()

        let showToolbarButton = app.buttons["showToolbarButton"]
        XCTAssertTrue(showToolbarButton.exists)

        showToolbarButton.tap()
        XCTAssertTrue(hideToolbarButton.exists)
    }

    @MainActor
    func testOpenBookmark() {
        let app = XCUIApplication()
        app.launch()

        let openBookmarksButton = app.buttons["openBookmarksButton"]
        openBookmarksButton.tap()

        let doneBookmarksButton = app.buttons["doneBookmarksButton"]
        XCTAssertTrue(doneBookmarksButton.exists)

        doneBookmarksButton.tap()
        XCTAssertTrue(openBookmarksButton.exists)
    }
}
