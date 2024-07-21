//
//  ImageCacheKitAssembly.swift
//
//
//  Created by Dmytro Vorko on 21/07/2024.
//

import DependencyInjector

public final class ImageCacheKitAssembly: Assembly {
    public init() {}
    
    public func assemble(resolver: any DependencyResolving) {
        resolver.registerDependency(type: ImageCacheKitProtocol.self, scope: .singleton) { _ in
            ImageCacheKit()
        }
    }
}
