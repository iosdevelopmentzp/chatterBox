//
//  ImageCacheKit.swift
//
//
//  Created by Dmytro Vorko on 21/07/2024.
//

import UIKit

public protocol ImageCacherProtocol {
    func saveImageToDisk(_ image: UIImage) async throws -> URL?
    func getImage(from url: URL) async -> UIImage?
    func getImages(from urls: [URL]) async -> [URL : UIImage]
}

final class ImageCacheKit: ImageCacherProtocol {
    enum CacheError: Error {
        case errorSavingFile(Error)
        case didntFindUrlPath
    }
    
    private let fileManager = FileManager.default
    
    private let cache: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()
        cache.countLimit = 50
        // set 100 mb limit
        cache.totalCostLimit = 100 * 1024 * 1024
        return cache
    }()
    
    private let queue = DispatchQueue(label: "ChatterBoxEngine.ImagesManager.queue")
    
    private var documentsDirectory: URL? {
        try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    public func saveImageToDisk(_ image: UIImage) async throws -> URL? {
        try queue.asyncAndWait(execute: {
            let uniqueID = UUID().uuidString
            guard 
                let data = image.jpegData(compressionQuality: 1.0),
                let fileURL = self.documentsDirectory?.appendingPathComponent("\(uniqueID).jpg") else {
                throw CacheError.didntFindUrlPath
            }
  
            do {
                try data.write(to: fileURL)
                return fileURL
            } catch {
                throw CacheError.errorSavingFile(error)
            }
        })
    }
    
    public func getImages(from urls: [URL]) async -> [URL : UIImage] {
        await withTaskGroup(of: (URL, UIImage?).self) { group in
            var images: [URL : UIImage] = [:]
            
            for url in urls {
                group.addTask { [weak self] in
                    guard let self = self else { return (url, nil) }
                    return (url, await self.getImage(from: url))
                }
            }
            
            for await (url, image) in group {
                if let image = image {
                    images[url] = image
                }
            }
            return images
        }
    }
    
    public func getImage(from url: URL) async -> UIImage? {
        queue.asyncAndWait {
            if let cachedImage = self.cache.object(forKey: url as NSURL) {
                return cachedImage
            }
            
            if let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
                self.cache.setObject(image, forKey: url as NSURL)
                return image
            }
            
            return nil
        }
    }
}
