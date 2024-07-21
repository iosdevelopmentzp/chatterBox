//
//  CoreStorageServiceFactory.swift
//
//
//  Created by Dmytro Vorko on 21/07/2024.
//

import Foundation
import CoreData

public protocol CoreStorageServiceFactoryProtocol {
    func makeChatterBoxerStorageService(persistentContainer: NSPersistentContainer) -> ChatterBoxCoreStorageServiceProtocol
}

public final class CoreStorageServiceFactory: CoreStorageServiceFactoryProtocol {
    public func makeChatterBoxerStorageService(persistentContainer: NSPersistentContainer) -> ChatterBoxCoreStorageServiceProtocol {
        ChatterBoxCoreStorageService(persistentContainer: persistentContainer)
    }
}
