/*
 ShareViewController.swift
 TelescopureShare

 Created by Takuto Nakamura on 2023/10/19.
*/

import UserInterface
import SwiftUI

final class ShareViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let shareView = ShareView(store: .init(
            viewController: self,
            uiApplicationClient: .liveValue,
            uiViewControllerClient: .liveValue
        ))
        let vc = UIHostingController(rootView: shareView)
        self.addChild(vc)
        containerView.addSubview(vc.view)
        vc.didMove(toParent: self)

        self.view.backgroundColor = .clear
        containerView.backgroundColor = .clear
        vc.view.backgroundColor = UIColor.clear
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        vc.view.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        vc.view.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        vc.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
}
