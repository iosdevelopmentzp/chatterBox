//
//  ChatCoordinator.swift
//
//
//  Created by Dmytro Vorko on 20/07/2024.
//

import UIKit

final class ChatCoordinator: NavigationCoordinator {
    override func start() {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .red
        navigationController.pushViewController(viewController, animated: true)
    }
}
