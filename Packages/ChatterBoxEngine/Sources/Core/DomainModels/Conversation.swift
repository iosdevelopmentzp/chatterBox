//
//  Conversation.swift
//  
//
//  Created by Dmytro Vorko on 21/07/2024.
//

import Foundation

public struct Conversation: Equatable {
    public let id: String
    public let participantsID: [String]
    public let messages: [Message]
    public let title: String?
    public let lastMessage: String?
    public let lastMessageTime: Date?
    
    public init(
        id: String,
        participantsID: [String],
        messages: [Message],
        title: String? = nil,
        lastMessage: String? = nil,
        lastMessageTime: Date? = nil
    ) {
        self.id = id
        self.participantsID = participantsID
        self.messages = messages
        self.title = title
        self.lastMessage = lastMessage
        self.lastMessageTime = lastMessageTime
    }
}
