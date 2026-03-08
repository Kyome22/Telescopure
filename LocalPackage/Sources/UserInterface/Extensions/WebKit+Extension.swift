import WebKit

extension WKWebView {
    override open var safeAreaInsets: UIEdgeInsets { .zero }
}

extension WKWebViewConfiguration {
    @MainActor
    static var forTelescopure: WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlinePredictions = true
        configuration.applicationNameForUserAgent = "Safari/604.1"
        return configuration
    }
}
