/*
  MinBrowserApp.swift
  MinBrowser

  Created by Takuto Nakamura on 2022/04/02.
*/

import SwiftUI

@main
struct MinBrowserApp: App {
    var body: some Scene {
        WindowGroup {
            WebView(viewModel: WebViewModel())
        }
    }
}
