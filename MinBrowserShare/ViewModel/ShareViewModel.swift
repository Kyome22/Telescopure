//
//  ShareViewModel.swift
//  MinBrowserShare
//
//  Created by Takuto Nakamura on 2022/04/02.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

protocol ShareViewModelProtocol: ObservableObject {
    var urlText: String { get set }

    func setURLText()
    func cancel()
    func open()
}

class ShareViewModel: ShareViewModelProtocol {
    @Published var urlText: String = ""

    private let vc: UIViewController
    private var url: URL? = nil

    init(vc: UIViewController) {
        self.vc = vc
    }

    func setURLText() {
        Task {
            do {
                let context = await vc.extensionContext
                url = try await extractSharedItem(from: context)
                if let urlString = url?.absoluteString {
                    urlText = (255 < urlString.count) ? urlString.prefix(255) + "…" : urlString
                }
            } catch(let error) {
                await vc.extensionContext?.cancelRequest(withError: error)
            }
        }
    }

    func extractSharedItem(from context: NSExtensionContext?) async throws -> URL {
        guard let item = context?.inputItems.first as? NSExtensionItem,
              let attachment = item.attachments?.first,
              attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier)
        else {
            throw NSError(domain: "com.kyome.MinBrowser",
                          code: 404,
                          userInfo: ["Reason" : "Non-URL item"])
        }
        let loadedItem = try await attachment.loadItem(forTypeIdentifier: UTType.url.identifier)
        guard let url = loadedItem as? URL else {
            throw NSError(domain: "com.kyome.MinBrowser",
                          code: 404,
                          userInfo: ["Reason" : "Non-URL item"])
        }
        return url
    }

    func cancel() {
        let error = NSError(domain: "com.kyome.MinBrowser",
                            code: 404,
                            userInfo: ["Reason" : "Canceled"])
        vc.extensionContext?.cancelRequest(withError: error)
    }

    func open() {
        defer {
            vc.extensionContext?.completeRequest(returningItems: [])
        }
        guard let urlString = url?.absoluteString,
              let encoded = urlString.percentEncoded,
              let shareURL = URL(string: "minbrowser://?url=\(encoded)")
        else {
            return
        }
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

