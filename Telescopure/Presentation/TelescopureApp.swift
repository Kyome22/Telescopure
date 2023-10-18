/*
 TelescopureApp.swift
 Telescopure

 Created by Takuto Nakamura on 2023/10/19.
*/

import SwiftUI

@main
struct TelescopureApp: App {
    var body: some Scene {
        WindowGroup {
            WebView(viewModel: WebViewModel())
        }
    }
}
