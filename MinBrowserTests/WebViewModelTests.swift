//
//  WebViewModelTests.swift
//  MinBrowserTests
//
//  Created by Takuto Nakamura on 2022/09/08.
//

import XCTest
import WebKit
@testable import MinBrowser

final class WebViewModelTests: XCTestCase {
    func testSearchEmpty() throws {
        let actual = WebViewModel()
        let webView = WKWebViewMock()
        actual.setWebView(webView)
        let userDefaults = try XCTUnwrap(UserDefaults(suiteName: "Test"))
        userDefaults.register(defaults: ["search-engine": "google"])
        actual.search(with: "", userDefaults: userDefaults)
        let expect = SearchEngine.google.url
        XCTAssertEqual(webView.url?.absoluteString, expect)
    }

    func testSearchKeywords() throws {
        let actual = WebViewModel()
        let webView = WKWebViewMock()
        actual.setWebView(webView)
        let userDefaults = try XCTUnwrap(UserDefaults(suiteName: "Test"))
        userDefaults.register(defaults: ["search-engine": "google"])
        actual.search(with: "うどん大好き", userDefaults: userDefaults)
        let expect = "https://www.google.com/search?q=%E3%81%86%E3%81%A9%E3%82%93%E5%A4%A7%E5%A5%BD%E3%81%8D"
        XCTAssertEqual(webView.url?.absoluteString, expect)
    }

    func testSearchURL() throws {
        let actual = WebViewModel()
        let webView = WKWebViewMock()
        actual.setWebView(webView)
        let userDefaults = try XCTUnwrap(UserDefaults(suiteName: "Test"))
        userDefaults.register(defaults: ["search-engine": "google"])
        actual.search(with: "https://kyome.io/index.html?lang=en#worksSection", userDefaults: userDefaults)
        let expect = "https://kyome.io/index.html?lang=en#worksSection"
        XCTAssertEqual(webView.url?.absoluteString, expect)
    }
}

private class WKWebViewMock: WKWebView {
    private var testURL: URL?

    override var url: URL? {
        return testURL
    }

    override func load(_ request: URLRequest) -> WKNavigation? {
        testURL = request.url
        return nil
    }
}
