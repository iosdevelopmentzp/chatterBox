//
//  ChatterBoxCoreStorageService.swift
//  
//
//  Created by Dmytro Vorko on 21/07/2024.
//

import Foundation
import CoreData

public protocol ChatterBoxCoreStorageServiceProtocol {
    var viewContext: NSManagedObjectContext { get }
}

final class ChatterBoxCoreStorageService: ChatterBoxCoreStorageServiceProtocol {
    private let persistentContainer: NSPersistentContainer
    
    lazy var viewContext: NSManagedObjectContext = {
        persistentContainer.viewContext
    }()
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
}
