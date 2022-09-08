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
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                if !viewModel.hideToolBar {
                    Group {
                        SearchBar(
                            inputText: $viewModel.inputText,
                            searchHandler: { inputText in
                                viewModel.search(with: inputText)
                            }
                        )
                        ProgressView(value: viewModel.estimatedProgress)
                            .opacity(viewModel.progressOpacity)
                    }
                    .transition(.move(edge: .top))
                }
                ZStack(alignment: .center) {
                    WrappedWKWebView(viewModel: viewModel)
                    if viewModel.url == nil {
                        LogoView()
                    }
                }
                if !viewModel.hideToolBar {
                    ToolBar(
                        hideToolBar: $viewModel.hideToolBar,
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
                    .transition(.move(edge: .bottom))
                }
            }
            .background(Color.secondarySystemBackground)
            if viewModel.hideToolBar {
                ShowToolBarButton(hideToolBar: $viewModel.hideToolBar)
                    .transition(.opacity)
            }
        }
        .onOpenURL(perform: { url in
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let queryItem = components.queryItems?.first
            else { return }
            if queryItem.name == "link", var link = queryItem.value {
                if let fragment = url.fragment {
                    link += "#\(fragment)"
                }
                viewModel.search(with: link)
            }
            if queryItem.name == "plaintext", let plainText = queryItem.value {
                // plainText is already removed percent-encoding.
                viewModel.search(with: plainText)
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
