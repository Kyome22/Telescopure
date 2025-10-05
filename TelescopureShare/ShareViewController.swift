import SwiftUI
import UserInterface

final class ShareViewController: UIViewController {
    @IBOutlet weak var hostingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let shareView = ShareView(store: .init(
            nsExtensionContextClient: .liveValue,
            extensionContext: { [weak self] in self?.extensionContext },
            openURL: { [weak self] in self?.open(url: $0) }
        ))
        let vc = UIHostingController(rootView: shareView)
        self.addChild(vc)
        hostingView.addSubview(vc.view)
        vc.didMove(toParent: self)

        self.view.backgroundColor = .clear
        hostingView.backgroundColor = .clear
        vc.view.backgroundColor = .clear
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.topAnchor.constraint(equalTo: hostingView.topAnchor).isActive = true
        vc.view.leftAnchor.constraint(equalTo: hostingView.leftAnchor).isActive = true
        vc.view.rightAnchor.constraint(equalTo: hostingView.rightAnchor).isActive = true
        vc.view.bottomAnchor.constraint(equalTo: hostingView.bottomAnchor).isActive = true
    }

    private func open(url: URL) {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                application.open(url)
                break
            }
            responder = responder?.next
        }
    }
}
