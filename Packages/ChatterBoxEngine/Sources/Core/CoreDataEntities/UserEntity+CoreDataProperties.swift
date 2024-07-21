//
//  UserEntity+CoreDataProperties.swift
//  ChatterBox
//
//  Created by Dmytro Vorko on 21/07/2024.
//
//

import Foundation
import CoreData


extension UserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }

    @NSManaged public var userID: String?
    @NSManaged public var username: String?
    @NSManaged public var conversations: NSSet?
    @NSManaged public var messages: NSSet?

}

// MARK: Generated accessors for conversations
extension UserEntity {

    @objc(addConversationsObject:)
    @NSManaged public func addToConversations(_ value: ConversationEntity)

    @objc(removeConversationsObject:)
    @NSManaged public func removeFromConversations(_ value: ConversationEntity)

    @objc(addConversations:)
    @NSManaged public func addToConversations(_ values: NSSet)

    @objc(removeConversations:)
    @NSManaged public func removeFromConversations(_ values: NSSet)

}

// MARK: Generated accessors for messages
extension UserEntity {

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: MessageEntity)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: MessageEntity)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)

}
