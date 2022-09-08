//
//  SearchBar.swift
//  MinBrowser
//
//  Created by Takuto Nakamura on 2022/04/02.
//

import SwiftUI

struct SearchBar: View {
    @Binding var inputText: String
    private let searchHandler: (String) -> Void

    init(
        inputText: Binding<String>,
        searchHandler: @escaping (String) -> Void
    ) {
        _inputText = inputText
        self.searchHandler = searchHandler
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.systemGray5)
            HStack(spacing: 4) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.systemGray)
                TextField("search", text: $inputText)
                    .accessibilityIdentifier("searchTextField")
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .foregroundColor(.systemGray)
                    .onSubmit {
                        searchHandler(inputText)
                    }
                Button {
                    inputText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(inputText.isEmpty ? .systemGray3 : .systemGray)
                }
                .accessibilityIdentifier("clearButton")
                .disabled(inputText.isEmpty)
            }
            .padding(.horizontal, 8)
        }
        .frame(height: 36)
        .cornerRadius(10)
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color("Header"))
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(inputText: .constant(""),
                  searchHandler: { _ in })
    }
}
