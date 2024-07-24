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
import UIComponentsKit

final class ImagePickerCoordinator: NavigationCoordinator {
    private let dependencyInjector: DependencyInjector
    private let completion: ([String]) -> Void
    private var picker: PHPickerViewController?
    
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
    
    private func handleResults(_ results: [PHPickerResult], picker: PHPickerViewController) {
        let itemProviders = results.map(\.itemProvider)
        var selectedImages: [UIImage] = []
        var loadError: Error?
        let group = DispatchGroup()

        for itemProvider in itemProviders where itemProvider.canLoadObject(ofClass: UIImage.self) {
            group.enter()
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                defer { group.leave() }  // Ensure that leave is called in all paths
                if let image = image as? UIImage {
                    selectedImages.append(image)
                } else if let error = error {
                    debugPrint("Error loading image: \(error.localizedDescription)")
                    loadError = error
                }
            }
        }
        
        presentLoader(on: picker, completion: nil)
        
        group.notify(queue: .main) { [weak self] in
            self?.dismissLoader(on: picker, completion: {
                if let loadError {
                    self?.presentErrorAlert(error: loadError, on: picker)
                } else {
                    picker.dismiss(animated: true) {
                        self?.presentImageConfirmationView(images: selectedImages)
                        self?.picker = picker
                    }
                }
            })
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
    
    private func presentImagePicker(picker: PHPickerViewController? = nil) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            showPicker()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    if status == .authorized || status == .limited {
                        self?.showPicker()
                    } else {
                        self?.presentAccessDeniedAlert()
                    }
                }
            }
        default:
            presentAccessDeniedAlert()
        }
    }
    
    private func showPicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 10
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        self.navigationController.present(picker, animated: true)
        self.picker = picker
    }
    
    private func presentLoader(on viewController: UIViewController, completion: (() -> Void)?) {
        let loader = LoaderViewController()
        loader.present(from: viewController, completion: completion)
    }
    
    private func dismissLoader(on viewController: UIViewController, completion: (() -> Void)?) {
        let loaderViewController = viewController.presentedViewController as? LoaderViewController
        if let loaderViewController {
            loaderViewController.dismissLoader(completion: completion)
        } else {
            completion?()
        }
    }
    
    private func presentErrorAlert(error: Error, on viewController: UIViewController) {
        let alert = UIAlertController(title: "Error", message: "Failed to load images: \(error.localizedDescription)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        viewController.present(alert, animated: true)
    }
    
    private func presentAccessDeniedAlert() {
        let alert = UIAlertController(
            title: "Access Denied",
            message: "Please enable access to your photos in settings to send images.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.navigationController.present(alert, animated: true)
    }
}

extension ImagePickerCoordinator: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard results.count > 0 else {
            picker.dismiss(animated: true) {
                self.childDidFinish(self)
            }
            return
        }
        self.handleResults(results, picker: picker)
    }
}

extension ImagePickerCoordinator: ImageConfirmationDelegate {
    func didTapCancel() {
        if let presented = self.navigationController.presentedViewController {
            presented.dismiss(animated: true, completion: {
                self.presentImagePicker(picker: self.picker)
            })
        }
    }
    
    func didConfirm(urls: [String]) {
        self.picker = nil
        
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
