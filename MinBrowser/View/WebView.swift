//
//  WebView.swift
//  MinBrowser
//
//  Created by Takuto Nakamura on 2022/04/02.
//

import SwiftUI

struct WebView<T: WebViewModelProtocol>: View {
    @StateObject var viewModel: T

    var body: some View {
        ZStack(alignment: .center) {
            VStack(spacing: 0) {
                SearchBar(
                    inputText: $viewModel.inputText,
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
            .background(Color.secondarySystemBackground)
            if viewModel.url == nil {
                VStack(spacing: 4) {
                    Image("MonoIcon")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                    Text("MinBrowser")
                        .italic()
                        .bold()
                }
                .foregroundColor(Color.systemGray5)
            }
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
            .previewInterfaceOrientation(.landscapeRight)
    }
}
