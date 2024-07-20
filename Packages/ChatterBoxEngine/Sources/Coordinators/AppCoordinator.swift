//
//  AppCoordinator.swift
//
//
//  Created by Dmytro Vorko on 20/07/2024.
//

import Foundation

import Foundation
import UIKit

public final class AppCoordinator: NavigationCoordinator {
    // MARK: - Properties
    
    private let window: UIWindow
    
    // MARK: - Constructor
    
    public init(window: UIWindow) {
        self.window = window
        let navigationController = UINavigationController()
        navigationController.view.backgroundColor = .white
        super.init(navigationController: navigationController)
    }
    
    // MARK: - Constructor
    
    public override func start() {
        window.rootViewController = navigationController
        let chatCoordinator = ChatCoordinator(navigationController: navigationController)
        addChild(chatCoordinator)
        chatCoordinator.start()
        window.makeKeyAndVisible()
    }
}
