//
//  SceneDelegate.swift
//  PlaytiniTestApp
//
//  Created by Дмитрий Процак on 26.12.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        let window = UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = .dark
        let viewController = PlaytiniViewController()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        self.window = window
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        if let viewController = window?.rootViewController as? PlaytiniViewController {
            viewController.rotateCircle()
        }
    }
}

