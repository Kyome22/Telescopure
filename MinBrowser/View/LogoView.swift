//
//  LogoView.swift
//  MinBrowser
//
//  Created by Takuto Nakamura on 2022/08/12.
//

import SwiftUI

struct LogoView: View {
    var body: some View {
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

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView()
    }
}
