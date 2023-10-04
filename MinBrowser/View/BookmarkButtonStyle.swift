/*
 BookmarkButtonStyle.swift
 MinBrowser

 Created by Takuto Nakamura on 2023/10/04.
 
*/

import SwiftUI

struct BookmarkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
        }
        .contentShape(Rectangle())
        .opacity(configuration.isPressed ? 0.3 : 1.0)
    }
}

extension ButtonStyle where Self == BookmarkButtonStyle {
    static var bookmark: BookmarkButtonStyle {
        return BookmarkButtonStyle()
    }
}
