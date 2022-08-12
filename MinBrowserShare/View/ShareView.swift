//
//  ShareView.swift
//  MinBrowserShare
//
//  Created by Takuto Nakamura on 2022/04/02.
//

import SwiftUI

struct ShareView<T: ShareViewModelProtocol>: View {
    @StateObject var viewModel: T

    var body: some View {
        VStack(spacing: 0) {
            Button {
                viewModel.cancel()
            } label: {
                Text(LocalizedStringKey("cancel"))
                    .padding(16)
            }
            .contentShape(Rectangle())
            Divider()
            Text(viewModel.urlText)
                .lineLimit(7)
                .foregroundColor(Color.primary)
                .padding(16)
            Divider()
            Button {
                viewModel.open()
            } label: {
                Text(LocalizedStringKey("open_in"))
                    .padding(16)
            }
            .contentShape(Rectangle())
        }
        .background(Color.systemGray5)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 8)
        .padding(40)
    }
}

struct ShareView_Previews: PreviewProvider {
    static var previews: some View {
        ShareView(viewModel: ShareViewModelMock())
    }
}
