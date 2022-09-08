//
//  WebViewModelTests.swift
//  MinBrowserTests
//
//  Created by Takuto Nakamura on 2022/09/08.
//

import XCTest
@testable import MinBrowser

final class WebViewModelTests: XCTestCase {
    func testSearchEmpty() throws {
        let actual = WebViewModel()
        let userDefaults = try XCTUnwrap(UserDefaults(suiteName: "Test"))
        userDefaults.register(defaults: ["search-engine": "google"])
        actual.search(with: "", userDefaults: userDefaults)
        let expect = SearchEngine.google.url
        let isActionEqual: Bool = {
            if case .search(expect) = actual.action {
                return true
            } else {
                return false
            }
        }()
        XCTAssertTrue(isActionEqual)
    }

    func testSearchKeywords() throws {
        let actual = WebViewModel()
        let userDefaults = try XCTUnwrap(UserDefaults(suiteName: "Test"))
        userDefaults.register(defaults: ["search-engine": "google"])
        actual.search(with: "うどん大好き", userDefaults: userDefaults)
        let expect = "https://www.google.com/search?q=%E3%81%86%E3%81%A9%E3%82%93%E5%A4%A7%E5%A5%BD%E3%81%8D"
        let isActionEqual: Bool = {
            if case .search(expect) = actual.action {
                return true
            } else {
                return false
            }
        }()
        XCTAssertTrue(isActionEqual)
    }

    func testSearchURL() throws {
        let actual = WebViewModel()
        let userDefaults = try XCTUnwrap(UserDefaults(suiteName: "Test"))
        userDefaults.register(defaults: ["search-engine": "google"])
        actual.search(with: "https://kyome.io/index.html?lang=en#worksSection", userDefaults: userDefaults)
        let expect = "https://kyome.io/index.html?lang=en#worksSection"
        let isActionEqual: Bool = {
            if case .search(expect) = actual.action {
                return true
            } else {
                return false
            }
        }()
        XCTAssertTrue(isActionEqual)
    }
}
