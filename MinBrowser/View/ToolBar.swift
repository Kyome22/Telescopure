/*
  ToolBar.swift
  MinBrowser

  Created by Takuto Nakamura on 2022/04/02.
*/

import SwiftUI

struct ToolBar: View {
    @Binding var hideToolBar: Bool
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool

    private let goBackHandler: () -> Void
    private let goForwardHandler: () -> Void
    private let bookmarkHandler: () -> Void

    init(
        hideToolBar: Binding<Bool>,
        canGoBack: Binding<Bool>,
        canGoForward: Binding<Bool>,
        goBackHandler: @escaping () -> Void,
        goForwardHandler: @escaping () -> Void,
        bookmarkHandler: @escaping () -> Void
    ) {
        _hideToolBar = hideToolBar
        _canGoBack = canGoBack
        _canGoForward = canGoForward
        self.goBackHandler = goBackHandler
        self.goForwardHandler = goForwardHandler
        self.bookmarkHandler = bookmarkHandler
    }

    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .overlay(Color("Border"))
            HStack {
                Button {
                    goBackHandler()
                } label: {
                    Image(systemName: "chevron.backward")
                        .imageScale(.large)
                        .frame(width: 40, height: 40, alignment: .center)
                }
                .disabled(!canGoBack)
                Button {
                    goForwardHandler()
                } label: {
                    Image(systemName: "chevron.forward")
                        .imageScale(.large)
                        .frame(width: 40, height: 40, alignment: .center)
                }
                .disabled(!canGoForward)
                Spacer()
                Button {
                    bookmarkHandler()
                } label: {
                    Image(systemName: "book")
                        .imageScale(.large)
                        .frame(width: 40, height: 40, alignment: .center)
                }
                .accessibilityIdentifier("showBookmarkButton")
                Button {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        hideToolBar = true
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .imageScale(.large)
                        .frame(width: 40, height: 40, alignment: .center)
                }
                .accessibilityIdentifier("hideToolBarButton")
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color("Footer"))
        }
    }
}

struct ToolBar_Previews: PreviewProvider {
    static var previews: some View {
        ToolBar(hideToolBar: .constant(false),
                canGoBack: .constant(false),
                canGoForward: .constant(false),
                goBackHandler: {},
                goForwardHandler: {},
                bookmarkHandler: {})
    }
}
