//
//  ImageConfirmationViewModel.swift
//
//
//  Created by Dmytro Vorko on 22/07/2024.
//

import SwiftUI
import ImageCacheKit

public class ImageConfirmationViewModel: ObservableObject {
    @Published private(set) var images: [UIImage] = []
    private let imageCacher: ImageCacherProtocol
    
    private weak var sceneDelegate: ImageConfirmationDelegate?
    
    private var task: Task<(), Never>? {
        willSet { task?.cancel() }
    }
    
    public init(images: [UIImage], sceneDelegate: ImageConfirmationDelegate?, imageCacher: ImageCacherProtocol) {
        self.images = images
        self.sceneDelegate = sceneDelegate
        self.imageCacher = imageCacher
    }
    
    func didTapConfirm() {
        guard task == nil else {
            return
        }
        self.task = Task { [weak self] in
            var urls: [URL] = []
            for image in self?.images ?? [] {
                if let url = try? await self?.imageCacher.saveImageToDisk(image) {
                    urls.append(url)
                }
            }
            let urlStrings = urls.map { $0.absoluteString }
            DispatchQueue.main.async { [weak self] in
                self?.sceneDelegate?.didConfirm(urls: urlStrings)
            }
        }
    }
    
    func didTapCancel() {
        self.sceneDelegate?.didTapCancel()
    }
}
