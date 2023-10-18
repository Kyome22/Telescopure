/*
 ShareViewModel.swift
 TelescopureShare

 Created by Takuto Nakamura on 2022/04/02.
*/

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

final class ShareViewModel: ShareViewModelProtocol {
    @Published var sharedText: String = ""
    @Published var sharedTypeKey: LocalizedStringKey = ""

    private let vc: UIViewController
    private var sharedType: SharedType?

    init(vc: UIViewController) {
        self.vc = vc
    }

    func setSharedText() {
        extractSharedItem(from: vc.extensionContext) { [weak self] result in
            switch result {
            case .success(let sharedType):
                self?.sharedType = sharedType
                self?.sharedText = sharedType.sharedText
                self?.sharedTypeKey = sharedType.localizedKey
            case .failure(let error):
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.vc.extensionContext?.cancelRequest(withError: error)
                }
            }
        }
    }

    func extractSharedItem(
        from context: NSExtensionContext?,
        completion: @escaping (Result<SharedType, ShareError>) -> Void
    ) {
        guard let item = context?.inputItems.first as? NSExtensionItem,
              let attachment = item.attachments?.first
        else {
            completion(.failure(ShareError.nonAttachmentsItem))
            return
        }
        if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            attachment.loadItem(forTypeIdentifier: UTType.url.identifier) { loadedItem, _ in
                if let link = loadedItem as? URL {
                    completion(.success(.link(link)))
                } else {
                    completion(.failure(.nonURLItem))
                }
            }
        } else if attachment.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
            attachment.loadItem(forTypeIdentifier: UTType.plainText.identifier) { loadedItem, _ in
                if let text = loadedItem as? String {
                    let plainText = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    completion(.success(.plainText(plainText)))
                } else {
                    completion(.failure(.nonTextItem))
                }
            }
        } else {
            completion(.failure(.nonSupportedItem))
        }
    }

    func cancel() {
        vc.extensionContext?.cancelRequest(withError: ShareError.canceled)
    }

    func open() {
        defer {
            vc.extensionContext?.completeRequest(returningItems: [])
        }
        guard let shareURL = sharedType?.shareURL else { return }
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
