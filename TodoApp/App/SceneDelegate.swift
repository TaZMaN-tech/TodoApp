//
//  SceneDelegate.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 21.01.2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let rootViewController = TaskListAssembly.createModuleWithNavigation()
        
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        
        self.window = window
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        CoreDataStack.shared.saveViewContext()
    }
}

