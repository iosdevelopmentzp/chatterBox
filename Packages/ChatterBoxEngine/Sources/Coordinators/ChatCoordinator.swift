//
//  ChatCoordinator.swift
//
//
//  Created by Dmytro Vorko on 20/07/2024.
//

import UIKit
import Scenes_Chat

final class ChatCoordinator: NavigationCoordinator {
    override func start() {
        let viewModel = ChatViewModel()
        let viewController = ChatViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
