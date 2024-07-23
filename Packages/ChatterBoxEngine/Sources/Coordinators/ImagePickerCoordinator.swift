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
    private let completion: ([String]) -> Void
    
    init(
        navigationController: UINavigationController,
        dependencyInjector: DependencyInjector,
        completion: @escaping ([String]) -> Void
    ) {
        self.dependencyInjector = dependencyInjector
        self.completion = completion
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        self.presentImagePicker()
    }
    
    private func handleResults(_ results: [PHPickerResult]) {
        let itemProviders = results.map(\.itemProvider)
        var selectedImages: [UIImage] = []
        let group = DispatchGroup()

        for itemProvider in itemProviders where itemProvider.canLoadObject(ofClass: UIImage.self) {
            group.enter()
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                defer { group.leave() }  // Ensure that leave is called in all paths
                if let image = image as? UIImage {
                    selectedImages.append(image)
                } else if let error = error {
                    print("Error loading image: \(error.localizedDescription)")
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard !selectedImages.isEmpty else {
                guard let self = self else { return }
                self.childDidFinish(self)
                return
            }
            
            self?.presentImageConfirmationView(images: selectedImages)
        }
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
        if let presented = self.navigationController.presentedViewController {
            presented.dismiss(animated: true, completion: {
                self.presentImagePicker()
            })
        }
        
    }
    
    func didConfirm(urls: [String]) {
        let completion = { [weak self] in
            self?.completion(urls)
            self.map { $0.childDidFinish($0) }
        }
        
        guard let presented = self.navigationController.presentedViewController else {
            assertionFailure("Unexpected case")
            completion()
            return
        }
        
        presented.dismiss(animated: true) {
            completion()
        }
    }
}
