//
//  MessageContentEntity+CoreDataProperties.swift
//  ChatterBox
//
//  Created by Dmytro Vorko on 23/07/2024.
//
//

import Foundation
import CoreData


extension MessageContentEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageContentEntity> {
        return NSFetchRequest<MessageContentEntity>(entityName: "MessageContentEntity")
    }

    @NSManaged public var text: String?
    @NSManaged public var images: Set<ImageEntity>?
    @NSManaged public var message: MessageEntity?

}

// MARK: Generated accessors for images
extension MessageContentEntity {

    @objc(addImagesObject:)
    @NSManaged public func addToImages(_ value: ImageEntity)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: ImageEntity)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSSet)

}
