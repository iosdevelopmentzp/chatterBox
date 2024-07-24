//
//  AppCoordinator.swift
//
//
//  Created by Dmytro Vorko on 20/07/2024.
//

import UIKit
import DependencyInjector

public final class AppCoordinator: NavigationCoordinator {
    // MARK: - Properties
    
    private let window: UIWindow
    private let dependencyInjector: DependencyInjector
    
    // MARK: - Constructor
    
    public init(window: UIWindow, dependencyInjector: DependencyInjector) {
        self.window = window
        self.dependencyInjector = dependencyInjector
        let navigationController = UINavigationController()
        navigationController.view.backgroundColor = .white
        super.init(navigationController: navigationController)
    }
    
    // MARK: - Constructor
    
    public override func start() {
        window.rootViewController = navigationController
        
        let chatCoordinator = ChatCoordinator(
            navigationController: navigationController,
            dependencyInjector: dependencyInjector
        )
        
        addChild(chatCoordinator)
        chatCoordinator.parent = self
        chatCoordinator.start()
        window.makeKeyAndVisible()
    }
}
