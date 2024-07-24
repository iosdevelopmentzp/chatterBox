//
//  ConversationEntity+CoreDataProperties.swift
//  ChatterBox
//
//  Created by Dmytro Vorko on 24/07/2024.
//
//

import Foundation
import CoreData


extension ConversationEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ConversationEntity> {
        return NSFetchRequest<ConversationEntity>(entityName: "ConversationEntity")
    }

    @NSManaged public var conversationID: String?
    @NSManaged public var lastMessage: String?
    @NSManaged public var lastMessageTime: Date?
    @NSManaged public var title: String?
    @NSManaged public var lastUpdate: Date?
    @NSManaged public var messages: Set<MessageEntity>?
    @NSManaged public var participants: Set<UserEntity>?

}

// MARK: Generated accessors for messages
extension ConversationEntity {

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: MessageEntity)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: MessageEntity)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)

}

// MARK: Generated accessors for participants
extension ConversationEntity {

    @objc(addParticipantsObject:)
    @NSManaged public func addToParticipants(_ value: UserEntity)

    @objc(removeParticipantsObject:)
    @NSManaged public func removeFromParticipants(_ value: UserEntity)

    @objc(addParticipants:)
    @NSManaged public func addToParticipants(_ values: NSSet)

    @objc(removeParticipants:)
    @NSManaged public func removeFromParticipants(_ values: NSSet)

}
