/*
 ShareViewModelMock.swift
 TelescopureShare

 Created by Takuto Nakamura on 2022/08/12.
*/

import SwiftUI

final class ShareViewModelMock: ShareViewModelProtocol {
    @Published var sharedText: String = ""
    @Published var sharedTypeKey: LocalizedStringKey = ""

    func setSharedText() {
        sharedText = "https://zenn.dev/kyome/articles/710cde86537d45"
        sharedTypeKey = "openIn"
    }
    func cancel() { fatalError() }
    func open() { fatalError() }
}
