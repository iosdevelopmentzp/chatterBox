//
//  MainAssembly.swift
//
//
//  Created by Dmytro Vorko on 21/07/2024.
//

import Foundation
import CoreDataPersistents
import DependencyInjector
import CoreStorageService
import UseCases
import StorageServices

public class MainAssembly: Assembly {
    public init() {
        
    }
    
    public func assemble(resolver: any DependencyResolving) {
        PersistentContainerAssembly().assemble(resolver: resolver)
        CoreStorageServiceAssembly().assemble(resolver: resolver)
        UseCasesAssembly().assemble(resolver: resolver)
        StorageServicesAssembly().assemble(resolver: resolver)
    }
}
