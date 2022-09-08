//
//  ShareViewModel.swift
//  MinBrowserShare
//
//  Created by Takuto Nakamura on 2022/04/02.
//

import UIKit
import UniformTypeIdentifiers
import SwiftUI

protocol ShareViewModelProtocol: ObservableObject {
    var sharedText: String { get set }
    var sharedTypeKey: LocalizedStringKey { get set }

    func setSharedText()
    func cancel()
    func open()
}

enum SharedType {
    case link(URL)
    case plainText(String)

    var sharedText: String {
        switch self {
        case .link(let url):
            let urlString = url.absoluteString.removingPercentEncoding ?? url.absoluteString
            return (255 < urlString.count) ? urlString.prefix(255) + "…" : urlString
        case .plainText(let text):
            return (255 < text.count) ? text.prefix(255) + "…" : text
        }
    }

    var shareURL: URL? {
        switch self {
        case .link(let url):
            // url is already percent-encoded.
            return URL(string: "minbrowser://?link=\(url.absoluteString)")
        case .plainText(let text):
            guard let encoded = text.percentEncoded else { return nil }
            return URL(string: "minbrowser://?plaintext=\(encoded)")
        }
    }

    var localizedKey: LocalizedStringKey {
        switch self {
        case .link(_): return "open_in"
        case .plainText(_): return "search_in"
        }
    }
}

final class ShareViewModel: ShareViewModelProtocol {
    @Published var sharedText: String = ""
    @Published var sharedTypeKey: LocalizedStringKey = ""

    private let domain: String = "com.kyome.MinBrowser"
    private let vc: UIViewController
    private var sharedType: SharedType!

    init(vc: UIViewController) {
        self.vc = vc
    }

    func setSharedText() {
        Task {
            do {
                let context = await vc.extensionContext
                sharedType = try await extractSharedItem(from: context)
                sharedText = sharedType.sharedText
                sharedTypeKey = sharedType.localizedKey
            } catch(let error) {
                try! await Task.sleep(nanoseconds: UInt64(500_000_000))
                await vc.extensionContext?.cancelRequest(withError: error)
            }
        }
    }

    func extractSharedItem(from context: NSExtensionContext?) async throws -> SharedType {
        guard let item = context?.inputItems.first as? NSExtensionItem,
              let attachment = item.attachments?.first
        else {
            throw NSError(domain: domain, code: 404, userInfo: ["Reason": "Non-Attachments item"])
        }
        if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            let loadedItem = try await attachment.loadItem(forTypeIdentifier: UTType.url.identifier)
            guard let link = loadedItem as? URL else {
                throw NSError(domain: domain, code: 404, userInfo: ["Reason": "Non-URL item"])
            }
            return SharedType.link(link)
        }
        if attachment.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
            let loadedItem = try await attachment.loadItem(forTypeIdentifier: UTType.plainText.identifier)
            guard let text = loadedItem as? String else {
                throw NSError(domain: domain, code: 404, userInfo: ["Reason": "Non-Text item"])
            }
            let plainText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            return SharedType.plainText(plainText)
        }
        throw NSError(domain: domain, code: 404, userInfo: ["Reason": "Non-Supported item"])
    }

    func cancel() {
        let error = NSError(domain: domain, code: 404, userInfo: ["Reason": "Canceled"])
        vc.extensionContext?.cancelRequest(withError: error)
    }

    func open() {
        defer {
            vc.extensionContext?.completeRequest(returningItems: [])
        }
        guard let shareURL = sharedType.shareURL else { return }
        var responder: UIResponder? = vc
        while responder != nil {
            if let application = responder as? UIApplication {
                application.perform(sel_registerName("openURL:"), with: shareURL)
                break
            }
            responder = responder?.next
        }
    }
}
