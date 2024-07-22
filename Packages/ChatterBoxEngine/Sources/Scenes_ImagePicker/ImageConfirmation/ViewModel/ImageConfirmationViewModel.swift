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
    
    public init(images: [UIImage], sceneDelegate: ImageConfirmationDelegate?, imageCacher: ImageCacherProtocol) {
        self.images = images
        self.sceneDelegate = sceneDelegate
        self.imageCacher = imageCacher
    }
}
