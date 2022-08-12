//
//  ShareViewModelMock.swift
//  MinBrowserShare
//
//  Created by Takuto Nakamura on 2022/08/12.
//

import Foundation

final class ShareViewModelMock: ShareViewModelProtocol {
    @Published var urlText: String = ""

    func setURLText() {
        urlText = "https://zenn.dev/kyome/articles/710cde86537d45"
    }
    func cancel() { fatalError() }
    func open() { fatalError() }
}
