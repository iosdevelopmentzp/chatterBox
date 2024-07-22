//
//  ImageConfirmationViewModel.swift
//
//
//  Created by Dmytro Vorko on 22/07/2024.
//

import SwiftUI

public class ImageConfirmationViewModel: ObservableObject {
    @Published private(set) var images: [UIImage] = []
    
    private weak var sceneDelegate: ImageConfirmationDelegate?
    
    init(images: [UIImage], sceneDelegate: ImageConfirmationDelegate?) {
        self.images = images
        self.sceneDelegate = sceneDelegate
    }
}
