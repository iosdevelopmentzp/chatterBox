//
//  ChatCoordinator.swift
//
//
//  Created by Dmytro Vorko on 20/07/2024.
//

import UIKit
import DependencyInjector
import Scenes_Chat

final class ChatCoordinator: NavigationCoordinator {
    private let dependencyInjector: DependencyInjector
    
    init(navigationController: UINavigationController, dependencyInjector: DependencyInjector) {
        self.dependencyInjector = dependencyInjector
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let viewModel = ChatViewModel(
            userUseCase: dependencyInjector.resolveDependency(),
            chatUseCase: dependencyInjector.resolveDependency()
        )
        
        let viewController = ChatViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
