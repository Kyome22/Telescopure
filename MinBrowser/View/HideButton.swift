//
//  HideButton.swift
//  MinBrowser
//
//  Created by Takuto Nakamura on 2022/08/12.
//

import SwiftUI

struct HideButton: View {
    @Binding var hideToolBar: Bool

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.4)) {
                hideToolBar = false
            }
        } label: {
            Image(systemName: "chevron.up")
                .imageScale(.large)
                .frame(width: 40, height: 40, alignment: .center)
        }
        .background(Color.systemGray5)
        .clipShape(Circle())
        .shadow(radius: 8)
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
}

struct HideButton_Previews: PreviewProvider {
    static var previews: some View {
        HideButton(hideToolBar: .constant(false))
    }
}
