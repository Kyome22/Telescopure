/*
 WKWebViewMock.swift
 Telescopure

 Created by Takuto Nakamura on 2023/10/19.
*/

import WebKit

final class WKWebViewMock: WKWebView {
    private var testURL: URL?

    override var url: URL? {
        return testURL
    }

    override func load(_ request: URLRequest) -> WKNavigation? {
        testURL = request.url
        return nil
    }
}
