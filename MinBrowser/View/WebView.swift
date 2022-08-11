//
//  WebView.swift
//  MinBrowser
//
//  Created by Takuto Nakamura on 2022/04/02.
//

import SwiftUI

struct WebView: View {
    @StateObject var viewModel = WebViewModel()
    @State var inputText: String = ""

    var body: some View {
        VStack(spacing: 0) {
            SearchBar(
                inputText: $inputText,
                searchHandler: { inputText in
                    viewModel.search(with: inputText)
                }
            )
            ProgressView(value: viewModel.estimatedProgress)
                .opacity(viewModel.progressOpacity)
            WrappedWKWebView(viewModel: viewModel)
            ToolBar(
                canGoBack: $viewModel.canGoBack,
                canGoForward: $viewModel.canGoForward,
                goBackHandler: {
                    viewModel.goBack()
                },
                goForwardHandler: {
                    viewModel.goForward()
                }
            )
        }
        .onOpenURL(perform: { url in
            NSLog("🐮 onOpenURL")
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let queryItem = components.queryItems?.first(where: { $0.name == "url" }),
               let queryURL = queryItem.value {
                viewModel.search(with: queryURL)
            }
        })
        .alert("", isPresented: $viewModel.showDialog, actions: {
            if viewModel.dialog == .prompt {
                // Prompt is only available on iOS 16 or later.
                // https://sarunw.com/posts/swiftui-alert-textfield/
                TextField(viewModel.promptDefaultText, text: $viewModel.promptImput)
            }
            Button("OK") {
                viewModel.dialogOK()
            }
            if viewModel.dialog != .alert {
                Button("Cancel", role: .cancel) {
                    viewModel.dialogCancel()
                }
            }
        }, message: {
            Text(viewModel.dialogMessage)
        })
    }
}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView()
    }
}
