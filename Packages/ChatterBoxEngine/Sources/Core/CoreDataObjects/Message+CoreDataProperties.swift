//
//  Message+CoreDataProperties.swift
//  ChatterBox
//
//  Created by Dmytro Vorko on 20/07/2024.
//
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var messageID: String?
    @NSManaged public var content: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var type: String?
    @NSManaged public var sender: User?
    @NSManaged public var conversation: Conversation?

}

extension Message : Identifiable {

}
