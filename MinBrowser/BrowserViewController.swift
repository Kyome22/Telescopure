//
//  BrowserViewController.swift
//  MinBrowser
//
//  Created by Takuto Nakamura on 2022/02/17.
//

import UIKit
import WebKit
import Combine

class BrowserViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    
    var initialURLString: String? = nil
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.autocapitalizationType = .none
        searchBar.delegate = self
        webView.uiDelegate = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl
        binding()
        openURL(urlString: initialURLString ?? "https://www.google.com")
    }
    
    private func binding() {
        webView.publisher(for: \.url, options: .new)
            .sink(receiveValue: { [searchBar] url in
                if let url = url {
                    searchBar?.text = url.absoluteString
                }
            })
            .store(in: &cancellables)
        
        progressView.isHidden = true
        webView.publisher(for: \.isLoading, options: .new)
            .sink(receiveValue: { [weak self] isLoading in
                self?.progressView.isHidden = !isLoading
                self?.progressView.setProgress(isLoading ? 0.1 : 0.0, animated: isLoading)
            })
            .store(in: &cancellables)
        webView.publisher(for: \.estimatedProgress, options: .new)
            .sink(receiveValue: { [progressView] estimatedProgress in
                progressView?.setProgress(Float(estimatedProgress), animated: true)
            })
            .store(in: &cancellables)
        
        backButton.isEnabled = false
        webView.publisher(for: \.canGoBack, options: .new)
            .sink(receiveValue: { [backButton] canGoBack in
                backButton?.isEnabled = canGoBack
            })
            .store(in: &cancellables)
        
        forwardButton.isEnabled = false
        webView.publisher(for: \.canGoForward, options: .new)
            .sink(receiveValue: { [forwardButton] canGoForward in
                forwardButton?.isEnabled = canGoForward
            })
            .store(in: &cancellables)
    }
    
    @IBAction func back(_ sender: Any) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @IBAction func forward(_ sender: Any) {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        webView.reload()
        sender.endRefreshing()
    }
    
    func openURL(urlString: String) {
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
    }
    
}

extension BrowserViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        searchBar.resignFirstResponder()
        if text.match(pattern: #"^[a-zA-Z]+://"#) {
            if text.hasPrefix("https://") || text.hasPrefix("http://") {
                openURL(urlString: text)
            } else if let url = URL(string: text) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else if let encoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let urlString = "https://www.google.com/search?q=\(encoded)"
            openURL(urlString: urlString)
        }
    }
    
}

// javaScript Alert, Confirm, Prompt -> UIAlert
extension BrowserViewController: WKUIDelegate {
    // Alert
    func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo
    ) async {
        return await withCheckedContinuation { continuation in
            let alertController = UIAlertController(title: nil,
                                                    message: message,
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                continuation.resume()
            }
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    // Confirm
    func webView(
        _ webView: WKWebView,
        runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo
    ) async -> Bool {
        return await withCheckedContinuation { continuation in
            let alertController = UIAlertController(title: nil,
                                                    message: message,
                                                    preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                continuation.resume(returning: false)
            }
            alertController.addAction(cancelAction)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                continuation.resume(returning: true)
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // Prompt
    func webView(
        _ webView: WKWebView,
        runJavaScriptTextInputPanelWithPrompt prompt: String,
        defaultText: String?,
        initiatedByFrame frame: WKFrameInfo
    ) async -> String? {
        return await withCheckedContinuation { continuation in
            let alertController = UIAlertController(title: nil,
                                                    message: prompt,
                                                    preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.text = defaultText
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                continuation.resume(returning: nil)
            }
            alertController.addAction(cancelAction)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                if let result = alertController.textFields?.first?.text {
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(returning: "")
                }
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

}
