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
            chatUseCase: dependencyInjector.resolveDependency(),
            imageCacher: self.dependencyInjector.resolveDependency(),
            sceneDelegate: self
        )
        
        let viewController = ChatViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension ChatCoordinator: ChatSceneDelegate {
    func didTapAttachImages(completion: @escaping ([String]) -> Void) {
        let coordinator = ImagePickerCoordinator(
            navigationController: self.navigationController,
            dependencyInjector: self.dependencyInjector,
            completion: completion
        )
        addChild(coordinator)
        coordinator.start()
    }
}
