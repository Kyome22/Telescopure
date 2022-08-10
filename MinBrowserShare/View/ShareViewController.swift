//
//  ShareViewController.swift
//  MinBrowserShare
//
//  Created by Takuto Nakamura on 2022/04/02.
//

import UIKit
import Social
import SwiftUI

class ShareViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!

    private var shareViewModel: ShareViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        shareViewModel = ShareViewModel(vc: self)
        shareViewModel.setURLText()
        let shareView = ShareView(viewModel: self.shareViewModel)
        let vc = UIHostingController(rootView: shareView)
        self.addChild(vc)
        containerView.addSubview(vc.view)
        vc.didMove(toParent: self)

        self.view.backgroundColor = .clear
        containerView.backgroundColor = .clear
        vc.view.backgroundColor = .clear
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        vc.view.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        vc.view.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        vc.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
}
