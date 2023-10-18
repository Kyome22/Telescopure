/*
 SearchBar.swift
 Telescopure

 Created by Takuto Nakamura on 2022/04/02.
*/

import SwiftUI

struct SearchBar: View {
    @Binding var inputText: String
    let searchHandler: (String) -> Void

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.systemGray5)
            HStack(spacing: 4) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.systemGray)
                TextField("search", text: $inputText)
                    .keyboardType(.webSearch)
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
        .background(Color.header)
    }
}

#Preview {
    SearchBar(inputText: .constant(""),
              searchHandler: { _ in })
}
