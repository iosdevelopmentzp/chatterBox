//
//  MessageImageCellModel.swift
//
//
//  Created by Dmytro Vorko on 23/07/2024.
//

import Foundation
import ImageCacheKit
import UIKit

struct MessageImageCellModel: Hashable {
    let id: String
    let imageURLs: [String]
    let isOutput: Bool
}

extension MessageImageCellModel {
    func getImages(
        cacher: ImageCacherProtocol,
        onUpdate: @escaping ((url: String, image: UIImage)) -> Void
    ) -> Task<(), Never>? {
        let urls = imageURLs.compactMap { URL(string: $0) }
        guard !urls.isEmpty else {
            return nil
        }
        return Task {
            for url in urls {
                guard let image = await cacher.getImage(from: url) else {
                    continue
                }
                guard !Task.isCancelled else { return }
                DispatchQueue.main.async {
                    onUpdate((url: url.absoluteString, image: image))
                }
            }
        }
    }
}
