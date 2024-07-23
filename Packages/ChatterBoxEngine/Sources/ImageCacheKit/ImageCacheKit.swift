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
    // MARK: - Nested
    enum CacheError: Error {
        case errorSavingFile(Error)
        case didntFindUrlPath
    }
    
    // MARK: - Properties
    
    private let fileManager = FileManager.default
    private let _cache = NSCache<NSURL, UIImage>()
    private let cacheAccessQueue = DispatchQueue(label: "com.chatterbox.ic.cacheAccess", attributes: .concurrent)
    private let queue = DispatchQueue(label: "com.chatterbox.ic.ioQueue")
    
    private var documentsDirectory: URL? {
        try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    // MARK: - Constructor
    
    init() {
        _cache.countLimit = 50
        // set 100 mb limit
        _cache.totalCostLimit = 100 * 1024 * 1024
    }
    
    // MARK: - Public Functions
    
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
        if let cachedImage = self.getCachedImage(url) {
            return cachedImage
        }
        
        return queue.asyncAndWait {
            // Resolve the potentially new path before fetching the image
            let resolvedURL = self.resolveURL(url)
            if let imageData = try? Data(contentsOf: resolvedURL), let image = UIImage(data: imageData) {
                self.setCachedImage(image: image, url: url)
                return image
            }
            
            return nil
        }
    }
}

// MARK: - Private extensions

private extension ImageCacheKit {
    private func getCachedImage(_ url: URL) -> UIImage? {
        cacheAccessQueue.asyncAndWait { [weak self] in
            self?._cache.object(forKey: url as NSURL)
        }
    }
    
    private func setCachedImage(image: UIImage, url: URL) {
        cacheAccessQueue.asyncAndWait { [weak self] in
            self?._cache.setObject(image, forKey: url as NSURL)
        }
    }
    
    private func resolveURL(_ url: URL) -> URL {
        // Reconstructs the file URL to adapt to changes in the app's document directory path between app launches,
        // a common occurrence during development installs. This dynamic resolution ensures consistent file access
        // across different sessions by appending the original file's last path component to the current document directory.

        // Fetch the current document directory.
        guard let documentDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            // If the directory can't be accessed, return the original URL as a fallback.
            return url
        }
        
        // Return a new URL combining the current document directory with the original file's last component.
        return documentDirectory.appendingPathComponent(url.lastPathComponent)
    }

}
