//
//  WebView.swift
//  MinBrowser
//
//  Created by Takuto Nakamura on 2022/04/02.
//

import SwiftUI

typealias AlertType = WebDialog

struct WebView<T: WebViewModelProtocol>: View {
    @StateObject var viewModel: T
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
                },
                bookmarkHandler: {
                    viewModel.showBookmark = true
                }
            )
        }
        .onOpenURL(perform: { url in
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let queryItem = components.queryItems?.first(where: { $0.name == "url" }),
               let queryURL = queryItem.value {
                viewModel.search(with: queryURL)
            }
        })
        .sheet(isPresented: $viewModel.showBookmark) {
            BookmarkView(
                currentTitle: viewModel.title,
                currentURL: viewModel.url,
                closeBookmarkHandler: {
                    viewModel.showBookmark = false
                }, loadBookmarkHandler: { url in
                    viewModel.showBookmark = false
                    viewModel.search(with: url)
                }
            )
        }
        .modifier(MigratedAlertModifier(viewModel: viewModel))
    }
}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(viewModel: WebViewModelMock())
    }
}
