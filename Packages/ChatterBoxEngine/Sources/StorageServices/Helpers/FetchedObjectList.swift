//
//  FetchedObjectList.swift
//
//
//  Created by Dmytro Vorko on 21/07/2024.
//

import Foundation
import CoreData
import Combine

final class FetchedObjectList<Object: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    // MARK: - Properties
    
    private var fetchedResultsController: NSFetchedResultsController<Object>
    private let onObjectsChange = CurrentValueSubject<[Object], Never>([])

    var objects: AnyPublisher<[Object], Never> {
        onObjectsChange.eraseToAnyPublisher()
    }
    
    // MARK: - Constructor

    init(fetchRequest: NSFetchRequest<Object>, context: NSManagedObjectContext) throws {
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        fetchedResultsController.delegate = self
        try fetchedResultsController.performFetch()
        sendCurrentObjects()
    }

    private func sendCurrentObjects() {
        onObjectsChange.send(fetchedResultsController.fetchedObjects ?? [])
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        sendCurrentObjects()
    }
}
