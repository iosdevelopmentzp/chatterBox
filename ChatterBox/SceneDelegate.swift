//
//  SceneDelegate.swift
//  ChatterBox
//
//  Created by Dmytro Vorko on 20/07/2024.
//

import UIKit
import Coordinators
import DependencyInjector
import MainAssembly

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var appCoordinator: AppCoordinator?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        let dependencyInjector = DependencyInjector()
        let mainAssembly = MainAssembly()
        dependencyInjector.setupAssemblies([mainAssembly])
        
        appCoordinator = AppCoordinator(window: window, dependencyInjector: dependencyInjector)
        
        appCoordinator?.start()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
}

