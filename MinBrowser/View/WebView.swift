//
//  WebView.swift
//  MinBrowser
//
//  Created by Takuto Nakamura on 2022/04/02.
//

import SwiftUI

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

final class WebViewModelMock: WebViewModelProtocol {
    @Published var action: WebAction = .none
    @Published var estimatedProgress: Double = 0.0
    @Published var progressOpacity: Double = 0.0
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false

    @Published var showDialog: Bool = false
    @Published var dialog: WebDialog = .alert
    @Published var dialogMessage: String = ""
    @Published var promptDefaultText: String = ""
    @Published var promptImput: String = ""

    @Published var showBookmark: Bool = false
    @Published var url: URL? = nil
    @Published var title: String? = nil

    func search(with text: String) { fatalError() }
    func goBack() { fatalError() }
    func goForward() { fatalError() }
    func reload() { fatalError() }

    func showAlert(message: String, completion: @escaping () -> Void) {
        fatalError()
    }
    func showConfirm(message: String, completion: @escaping (Bool) -> Void) {
        fatalError()
    }
    func showPrompt(prompt: String, defaultText: String?, completion: @escaping (String?) -> Void) {
        fatalError()
    }
    func dialogOK() { fatalError() }
    func dialogCancel() { fatalError() }
}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(viewModel: WebViewModelMock())
    }
}
