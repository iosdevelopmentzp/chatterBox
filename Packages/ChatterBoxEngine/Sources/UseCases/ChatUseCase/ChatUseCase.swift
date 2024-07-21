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

public protocol ChatUseCaseProtocol {
    func messagesPublisher(conversationID: String) -> AnyPublisher<[Message], Never>
}

final class ChatUseCase {
    private let storageService: ChatterBoxerLocalStorageServiceProtocol
    
    init(storageService: ChatterBoxerLocalStorageServiceProtocol) {
        self.storageService = storageService
    }
    
    func saveMessage(text: String, conversation: Conversation, senderID: String?) {
        let message = Message(
            id: String(UUID().hashValue),
            type: .text,
            conversationID: conversation.id,
            senderID: senderID,
            content: text,
            timestamp: Date()
        )
        
        self.storageService.saveMessage(message)
    }
    
    func deleteMessage(message: Message) {
        self.storageService.deleteMessage(message)
    }
    
    func messagesPublisher(conversationID: String) -> AnyPublisher<[Message], Never> {
        self.storageService
            .messagesPublisher(conversationID: conversationID)
    }
}
