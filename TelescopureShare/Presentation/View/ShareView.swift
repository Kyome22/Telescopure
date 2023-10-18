/*
 ShareView.swift
 TelescopureShare

 Created by Takuto Nakamura on 2022/04/02.
*/

import SwiftUI

struct ShareView<T: ShareViewModelProtocol>: View {
    @StateObject var viewModel: T

    var body: some View {
        VStack(spacing: 0) {
            Button {
                viewModel.cancel()
            } label: {
                Text(LocalizedStringKey("cancel"))
            }
            .padding(16)
            Rectangle()
                .frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1)
                .foregroundColor(Color.systemGray3)
            Text(viewModel.sharedText)
                .lineLimit(7)
                .foregroundColor(Color.primary)
                .padding(16)
            Rectangle()
                .frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1)
                .foregroundColor(Color.systemGray3)
            Button {
                viewModel.open()
            } label: {
                Text(viewModel.sharedTypeKey)
            }
            .padding(16)
        }
        .background(Color.systemGray5)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 8)
        .padding(40)
    }
}

#Preview {
    ShareView(viewModel: ShareViewModelMock())
}
