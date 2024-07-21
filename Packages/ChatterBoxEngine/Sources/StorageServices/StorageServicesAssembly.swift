//
//  StorageServicesAssembly.swift
//
//
//  Created by Dmytro Vorko on 21/07/2024.
//

import DependencyInjector

public final class StorageServicesAssembly: Assembly {
    public init() {}
    
    public func assemble(resolver: any DependencyResolving) {
        resolver.registerDependency(type: ChatterBoxerLocalStorageServiceProtocol.self, scope: .transient) { resolver in
            ChatterBoxerLocalStorageService(storageService: resolver.resolveDependency())
        }
    }
}
