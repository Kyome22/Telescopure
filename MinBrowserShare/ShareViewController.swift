//
//  ShareViewController.swift
//  MinBrowserShare
//
//  Created by Takuto Nakamura on 2022/02/17.
//

import UIKit
import WebKit
import MobileCoreServices
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var urlTextView: UITextView!
    @IBOutlet weak var openButton: UIButton!
    
    private var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        
        setupDialog()
        setupBorder()
        
        Task {
            do {
                url = try await extractSharedItem(from: self.extensionContext)
                if let urlString = url?.absoluteString {
                    urlTextView.text = (255 < urlString.count)
                    ? urlString.prefix(255) + "…"
                    : urlString
                }
            } catch(let error) {
                self.extensionContext?.cancelRequest(withError: error)
            }
        }
    }
    
    // MARK: Initialize User Interface
    private func setupDialog() {
        dialogView.layer.cornerRadius = 8
        dialogView.layer.shadowColor = UIColor.black.cgColor
        dialogView.layer.shadowOpacity = 0.6
        dialogView.layer.shadowRadius = 8
    }
    
    private func setupBorder() {
        let border1 = CALayer()
        border1.frame = CGRect(x: 0, y: cancelButton.frame.height - 1,
                               width: cancelButton.frame.width, height: 1)
        border1.backgroundColor = UIColor.systemGray3.cgColor
        cancelButton.layer.addSublayer(border1)
        
        let border2 = CALayer()
        border2.frame = CGRect(x: 0, y: 0, width: openButton.frame.width, height: 1)
        border2.backgroundColor = UIColor.systemGray3.cgColor
        openButton.layer.addSublayer(border2)
    }
    
    private func extractSharedItem(from context: NSExtensionContext?) async throws -> URL {
        guard let item = context?.inputItems.first as? NSExtensionItem,
              let attachment = item.attachments?.first,
              attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier)
        else {
            throw NSError(domain: "com.kyome.MinBrowser",
                          code: 404,
                          userInfo: ["Reason" : "No Attachment"])
        }
        let loadedItem = try await attachment.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil)
        guard let url = loadedItem as? URL else {
            throw NSError(domain: "com.kyome.MinBrowser",
                          code: 404,
                          userInfo: ["Reason" : "Non-URL item"])
        }
        return url
    }
    
    // MARK: Launch the Container App
    func openShareURL(_ url: URL) {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                application.perform(sel_registerName("openURL:"), with: url)
                break
            }
            responder = responder?.next
        }
    }
    
    @IBAction func pushCancel(_ sender: Any) {
        let error = NSError(domain: "com.kyome.MinBrowser",
                            code: 300,
                            userInfo: ["Reason" : "Canceled"])
        self.extensionContext?.cancelRequest(withError: error)
    }
    
    @IBAction func pushOpen(_ sender: Any) {
        defer {
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        }
        guard let urlString = url?.absoluteString,
              let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let shareURL = URL(string: "minbrowser://?url=\(encoded)")
        else {
            return
        }
        openShareURL(shareURL)
    }
    
}
