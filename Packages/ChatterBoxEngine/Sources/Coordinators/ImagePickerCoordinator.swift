//
//  ImagePickerCoordinator.swift
//
//
//  Created by Dmytro Vorko on 22/07/2024.
//

import UIKit
import DependencyInjector
import Scenes_ImagePicker
import PhotosUI

final class ImagePickerCoordinator: NavigationCoordinator {
    private let dependencyInjector: DependencyInjector
    
    init(
        navigationController: UINavigationController,
        dependencyInjector: DependencyInjector,
        completion: @escaping ([String]) -> Void
    ) {
        self.dependencyInjector = dependencyInjector
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        self.presentImagePicker()
    }
    
    private func handleResults(_ results: [PHPickerResult]) {
        var selectedImages: [UIImage] = []
        let itemProviders = results.map(\.itemProvider)
        for itemProvider in itemProviders where itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                if let image = image as? UIImage {
                    // Use the image for your purposes
                    selectedImages.append(image)
                } else if let error = error {
                    print("Error loading image: \(error.localizedDescription)")
                }
            }
        }
        
        guard selectedImages.count > 0 else {
            self.childDidFinish(self)
            return
        }
        
        self.presentImageConfirmationView(images: selectedImages)
    }
    
    private func presentImageConfirmationView(images: [UIImage]) {
        let viewController = ImageConfirmationViewController(
            viewModel: ImageConfirmationViewModel(
                images: images,
                sceneDelegate: self,
                imageCacher: dependencyInjector.resolveDependency()
            )
        )
        viewController.modalPresentationStyle = .fullScreen
        
        self.navigationController.present(viewController, animated: true)
    }
    
    private func presentImagePicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 10
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        self.navigationController.present(picker, animated: true)
    }
}

extension ImagePickerCoordinator: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) {
            self.handleResults(results)
        }
    }
}

extension ImagePickerCoordinator: ImageConfirmationDelegate {
    func didTapCancel() {
        self.presentImagePicker()
    }
    
    func didConfirm(urls: [String]) {
        if let presented = self.navigationController.presentedViewController {
            presented.dismiss(animated: true, completion: {
                self.childDidFinish(self)
            })
        }
    }
}
