//
//  PersistentContainerFactory.swift
//
//
//  Created by Dmytro Vorko on 20/07/2024.
//

import Foundation
import CoreData

final class PersistentContainerFactory {
    private lazy var chatterBoxPersistentContainer: NSPersistentContainer = {
        let modelName = "ChatterBox"
        let bundle = Bundle.module
        let modelURL = bundle.url(forResource: modelName, withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)!
        
        let container = NSPersistentContainer(name: modelName, managedObjectModel: managedObjectModel)
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("Unresolved Persistent Container error: \(error)")
            }
        }
        return container
    }()
    
    func makeChatterBoxPersistentContainer() -> NSPersistentContainer {
        self.chatterBoxPersistentContainer
    }
}
