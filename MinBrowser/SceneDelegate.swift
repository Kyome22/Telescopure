//
//  SceneDelegate.swift
//  MinBrowser
//
//  Created by Takuto Nakamura on 2022/02/15.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        let storyboard = UIStoryboard(name: "BrowserView", bundle: nil)
        let browserVC = storyboard.instantiateInitialViewController() as? BrowserViewController
        if let sharedURLString = getSharedURLString(connectionOptions.urlContexts) {
            browserVC?.initialURLString = sharedURLString
        }
        window?.rootViewController = browserVC
        window?.makeKeyAndVisible()
    }
    
    func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {
        if let sharedURLString = getSharedURLString(URLContexts) {
            if let rootVC = self.window?.rootViewController as? BrowserViewController {
                rootVC.openURL(urlString: sharedURLString)
            }
        }
    }
    
    private func getSharedURLString(_ URLContexts: Set<UIOpenURLContext>) -> String? {
        guard let url = URLContexts.first?.url,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItem = components.queryItems?.first(where: { $0.name == "url" }),
              let sharedURLString = queryItem.value
        else {
            return nil
        }
        return sharedURLString
    }

}

