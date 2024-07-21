//
//  PersistentContainerAssembly.swift
//
//
//  Created by Dmytro Vorko on 21/07/2024.
//

import DependencyInjector
import CoreData

public class PersistentContainerAssembly: Assembly {
    public init() {}
    
    public func assemble(resolver: any DependencyResolving) {
        resolver.registerDependency(type: NSPersistentContainer.self, scope: .singleton) { resolver in
            PersistentContainerFactory().makeChatterBoxPersistentContainer()
        }
    }
}
