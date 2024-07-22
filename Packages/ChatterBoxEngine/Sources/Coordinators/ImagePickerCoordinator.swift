//
//  ImagePickerCoordinator.swift
//
//
//  Created by Dmytro Vorko on 22/07/2024.
//

import UIKit
import DependencyInjector
import Scenes_ImagePicker

final class ImagePickerCoordinator: NavigationCoordinator {
    private let dependencyInjector: DependencyInjector
    
    init(navigationController: UINavigationController, dependencyInjector: DependencyInjector) {
        self.dependencyInjector = dependencyInjector
        super.init(navigationController: navigationController)
    }
    
    override func start() {

    }
    
    private func presentImageConfirmationView(images: [UIImage]) {
        let viewController = ImageConfirmationViewController(
            viewModel: ImageConfirmationViewModel(
                images: images,
                sceneDelegate: self,
                imageCacher: dependencyInjector.resolveDependency()
            )
        )
        
        self.navigationController.present(viewController, animated: true)
    }
}

extension ImagePickerCoordinator: ImageConfirmationDelegate {
    func didTapCancel() {
        
    }
    
    func didConfirm(urls: [String]) {
        
    }
}
