//
//  CoreDataToDomainAdapter.swift
//
//
//  Created by Dmytro Vorko on 25/07/2024.
//

import Foundation
import CoreData
import Core

struct CoreDataToDomainAdapter {
    // MARK: - Entity Updates
    
    func updateImageEntity(
        obj: ImageEntity,
        with url: String,
        messageContent: Set<MessageContentEntity>
    ) {
        obj.url = url
        obj.messageContents = messageContent
    }
    
    func updateMessageContentEntity(
        obj: MessageContentEntity,
        with content: Message.Content,
        images: Set<ImageEntity>?,
        message: MessageEntity
    ) {
        obj.text = content.text
        obj.images = images
        obj.message = message
    }
    
    func updateMessageEntity(
        obj: MessageEntity,
        with id: String?,
        type: Message.MessageType,
        content: MessageContentEntity,
        timestamp: Date
    ) {
        obj.messageID = id
        obj.type = type.rawValue
        obj.content = content
        obj.timestamp = timestamp
    }
    
    // MARK: - Core Data -> Domain
    
    func translateToConversation(entity: ConversationEntity) -> Conversation {
        let messages = (entity.messages?.map { self.translateToMessage(entity: $0) } ?? []).sorted(by: {
            $0.timestamp > $1.timestamp
        })
        return .init(
            id: entity.conversationID ?? "",
            participantsID: entity.participants?.compactMap { $0.userID } ?? [],
            messages: messages,
            title: entity.title,
            lastMessage: entity.lastMessage,
            lastMessageTime: entity.lastMessageTime
        )
    }
    
    func translateToUser(entity: UserEntity) -> User {
        .init(id: entity.userID ?? "", username: entity.username ?? "")
    }
    
    func translateToMessage(entity: MessageEntity) -> Message {
        let content = Message.Content(
            text: entity.content?.text,
            imageURLs: entity.content?.images?.compactMap { $0.url }.sorted(by: { $0 > $1 })
        )
        
        return .init(
            id: entity.messageID ?? "",
            type: entity.type.flatMap { Message.MessageType(rawValue: $0) } ?? .unknown,
            conversationID: entity.conversation?.conversationID,
            senderID: entity.sender?.userID,
            content: content,
            timestamp: entity.timestamp ?? Date()
        )
    }
}
