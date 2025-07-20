import SwiftUI
import UserInterface

final class ShareViewController: UIViewController {
    @IBOutlet weak var hostingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let shareView = ShareView(store: .init(
            viewController: self,
            uiApplicationClient: .liveValue,
            uiViewControllerClient: .liveValue
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
}
