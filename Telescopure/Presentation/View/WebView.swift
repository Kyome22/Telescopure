/*
 WebView.swift
 Telescopure

 Created by Takuto Nakamura on 2022/04/02.
*/

import SwiftUI

struct WebView<W: WebViewModelProtocol, B: BookmarkViewModelProtocol>: View {
    @StateObject var viewModel: W

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
                    WrappedWKWebView(setWebViewHandler: { webView in
                        viewModel.setWebView(webView)
                    })
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
        .ignoresSafeArea(edges: viewModel.hideToolBar ? .all : [])
        .onOpenURL { url in
            viewModel.openURL(with: url)
        }
        .sheet(isPresented: $viewModel.showBookmark) {
            BookmarkView(viewModel: B(
                currentTitle: viewModel.title,
                currentURL: viewModel.url,
                loadBookmarkHandler: { urlString in
                    viewModel.search(with: urlString)
                }
            ))
        }
        .alert("", isPresented: $viewModel.showDialog) {
            if case .prompt(_, let defaultText) = viewModel.webDialog {
                TextField(defaultText, text: $viewModel.promptInput)
            }
            Button("ok") {
                viewModel.dialogOK()
            }
            if !viewModel.webDialog.isAlert {
                Button("cancel", role: .cancel) {
                    viewModel.dialogCancel()
                }
            }
        } message: {
            Text(viewModel.webDialog.message)
        }
    }
}

#Preview {
    WebView<WebViewModelMock, BookmarkViewModelMock>(viewModel: WebViewModelMock())
        .previewInterfaceOrientation(.landscapeRight)
}
