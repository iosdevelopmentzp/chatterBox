//
//  Message.swift
//  
//
//  Created by Dmytro Vorko on 21/07/2024.
//

import Foundation

public struct Message: Equatable {
    public struct Content: Equatable {
        public let text: String?
        public let imageURLs: [String]?
        
        public init(text: String?, imageURLs: [String]?) {
            self.text = text
            self.imageURLs = imageURLs
        }
    }
    
    public enum MessageType: String {
        case text
        case image
        case unknown
    }
    
    public let id: String
    public let conversationID: String?
    public let type: MessageType
    public let senderID: String?
    public let content: Content
    public let timestamp: Date
    
    public init(
        id: String,
        type: Message.MessageType,
        conversationID: String?,
        senderID: String?,
        content: Message.Content,
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
