//
//  MessageEntity+CoreDataProperties.swift
//  ChatterBox
//
//  Created by Dmytro Vorko on 23/07/2024.
//
//

import Foundation
import CoreData


extension MessageEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageEntity> {
        return NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
    }

    @NSManaged public var messageID: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var type: String?
    @NSManaged public var conversation: ConversationEntity?
    @NSManaged public var sender: UserEntity?
    @NSManaged public var content: MessageContentEntity?

}
