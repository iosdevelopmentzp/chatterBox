//
//  CoreStorageServiceAssembly.swift
//
//
//  Created by Dmytro Vorko on 21/07/2024.
//

import DependencyInjector

public final class CoreStorageServiceAssembly: Assembly {
    public init() {}
    
    public func assemble(resolver: any DependencyResolving) {
        resolver.registerDependency(type: ChatterBoxCoreStorageServiceProtocol.self, scope: .weak) { resolver in
            ChatterBoxCoreStorageService(persistentContainer: resolver.resolveDependency())
        }
    }
}
