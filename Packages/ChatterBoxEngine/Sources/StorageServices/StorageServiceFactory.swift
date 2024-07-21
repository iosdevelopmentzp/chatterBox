//
//  StorageServiceFactory.swift
//
//
//  Created by Dmytro Vorko on 21/07/2024.
//

import Foundation
import CoreData

public protocol StorageServiceFactoryProtocol {
    func makeChatterBoxerLocalStorageService(mainContext: NSManagedObjectContext) -> ChatterBoxerLocalStorageServiceProtocol
}

final class StorageServiceFactory: StorageServiceFactoryProtocol {
    func makeChatterBoxerLocalStorageService(mainContext: NSManagedObjectContext) -> ChatterBoxerLocalStorageServiceProtocol {
        ChatterBoxerLocalStorageService(mainContext: mainContext)
    }
}
