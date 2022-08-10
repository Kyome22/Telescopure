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
                    .padding(8)
            }
            .contentShape(Rectangle())
            Divider()
            Text(viewModel.urlText)
                .lineLimit(7)
                .foregroundColor(Color.primary)
                .padding(4)
            Divider()
            Button {
                viewModel.open()
            } label: {
                Text(LocalizedStringKey("open_in"))
                    .padding(8)
            }
            .contentShape(Rectangle())
        }
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(radius: 8)
        .padding(40)
    }
}

class ShareViewModelMock: ShareViewModelProtocol {
    @Published var urlText: String = ""

    func setURLText() {
        urlText = "https://zenn.dev/kyome/articles/710cde86537d45"
    }
    func cancel() { Swift.print("push cancel") }
    func open() { Swift.print("push open") }
}

struct ShareView_Previews: PreviewProvider {
    static var previews: some View {
        ShareView(viewModel: ShareViewModelMock())
    }
}
