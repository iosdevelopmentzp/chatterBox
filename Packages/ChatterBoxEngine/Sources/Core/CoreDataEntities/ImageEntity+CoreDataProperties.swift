//
//  ImageEntity+CoreDataProperties.swift
//  ChatterBox
//
//  Created by Dmytro Vorko on 23/07/2024.
//
//

import Foundation
import CoreData


extension ImageEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageEntity> {
        return NSFetchRequest<ImageEntity>(entityName: "ImageEntity")
    }

    @NSManaged public var url: String?
    @NSManaged public var messageContents: Set<MessageContentEntity>?

}

// MARK: Generated accessors for messageContents
extension ImageEntity {

    @objc(addMessageContentsObject:)
    @NSManaged public func addToMessageContents(_ value: MessageContentEntity)

    @objc(removeMessageContentsObject:)
    @NSManaged public func removeFromMessageContents(_ value: MessageContentEntity)

    @objc(addMessageContents:)
    @NSManaged public func addToMessageContents(_ values: NSSet)

    @objc(removeMessageContents:)
    @NSManaged public func removeFromMessageContents(_ values: NSSet)

}
