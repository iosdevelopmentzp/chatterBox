//
//  ChatUseCase.swift
//
//
//  Created by Dmytro Vorko on 21/07/2024.
//

import Foundation
import Core
import StorageServices
import Combine

public enum UpdateMessageAction {
    case deleteImage(index: Int)
}

public protocol ChatUseCaseProtocol {
    func createConversation(title: String?, participantsID: [String])
    func getConversations(userID: String) -> [Conversation]
    
    func saveMessage(content: Message.Content, conversation: Conversation, senderID: String?) 
    func deleteMessage(id: String)
    func updateMessage(_ message: Message, change: UpdateMessageAction)
    func conversationPublisher(conversationID: String) -> AnyPublisher<Conversation, Never>
}

final class ChatUseCase: ChatUseCaseProtocol {
    private let storageService: ChatterBoxerLocalStorageServiceProtocol
    
    init(storageService: ChatterBoxerLocalStorageServiceProtocol) {
        self.storageService = storageService
    }
    
    // MARK: - ChatUseCaseProtocol
    
    func getConversations(userID: String) -> [Conversation] {
        storageService.getConversations(userID: userID)
    }
    
    func createConversation(title: String?, participantsID: [String]) {
        let conversation = Conversation(
            id: UUID().uuidString,
            participantsID: participantsID,
            messages: [],
            title: title, 
            lastMessage: nil,
            lastMessageTime: nil
        )
        storageService.saveConversation(conversation)
    }
    
    func saveMessage(content: Message.Content, conversation: Conversation, senderID: String?) {
        let type: Message.MessageType = {
            if !(content.text ?? "").isEmpty {
                return .text
            } else if !(content.imageURLs ?? []).isEmpty {
                return .image
            } else {
                return .unknown
            }
        }()
        
        guard type != .unknown else {
            return
        }
        
        let message = Message(
            id: String(UUID().hashValue),
            type: type,
            conversationID: conversation.id,
            senderID: senderID,
            content: content,
            timestamp: Date()
        )
        
        self.storageService.saveMessage(message)
    }
    
    func updateMessage(_ message: Message, change: UpdateMessageAction) {
        switch change {
        case .deleteImage(let index) where message.type == .image:
            var images = message.content.imageURLs ?? []
            if images.count > index {
                images.remove(at: index)
            }
            
            if images.isEmpty {
                self.storageService.deleteMessage(id: message.id)
            } else {
                let newContent = Message.Content(text: message.content.text, imageURLs: images)
                let updatedMessage = Message(
                    id: message.id,
                    type: message.type,
                    conversationID: message.conversationID,
                    senderID: message.senderID,
                    content: newContent,
                    timestamp: message.timestamp
                )
                self.storageService.updateMessage(updatedMessage)
            }
            
        default:
            return
        }
    }
    
    func deleteMessage(id: String) {
        self.storageService.deleteMessage(id: id)
    }
    
    func conversationPublisher(conversationID: String) -> AnyPublisher<Conversation, Never> {
        self.storageService
            .conversationPublisher(conversationID: conversationID)
    }
}
