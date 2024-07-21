//
//  Message.swift
//  
//
//  Created by Dmytro Vorko on 21/07/2024.
//

import Foundation

public struct Message: Equatable {
    public enum MessageType: String {
        case text
        case image
        case unknown
    }
    
    public let id: String
    public let conversationID: String?
    public let type: MessageType
    public let senderID: String?
    public let content: String
    public let timestamp: Date
    
    public init(
        id: String,
        type: Message.MessageType,
        conversationID: String?,
        senderID: String?,
        content: String,
        timestamp: Date
    ) {
        self.id = id
        self.conversationID = conversationID
        self.type = type
        self.senderID = senderID
        self.content = content
        self.timestamp = timestamp
    }
}
