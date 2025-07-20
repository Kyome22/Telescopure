import XCTest

final class TelescopureUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testSearchKeyword() throws {
        let app = XCUIApplication()
        app.launch()

        let searchTextField = app.textFields["searchTextField"]
        searchTextField.tap()
        searchTextField.typeText("apple\n")

        let actual = try XCTUnwrap(searchTextField.value as? String)
        let expect = "https://www.google.com/search?q=apple"
        XCTAssertEqual(actual, expect)
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
    func testHideToolBar() throws {
        let app = XCUIApplication()
        app.launch()

        let hideToolBarButton = app.buttons["hideToolBarButton"]
        hideToolBarButton.tap()

        let showToolBarButton = app.buttons["showToolBarButton"]
        XCTAssertTrue(showToolBarButton.exists)

        showToolBarButton.tap()
        XCTAssertTrue(hideToolBarButton.exists)
    }

    @MainActor
    func testOpenBookmark() throws {
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
