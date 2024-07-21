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
    func createConversation(title: String?, participantsID: [String])
    func getConversations(userID: String) -> [Conversation]
    
    func saveMessage(text: String, conversation: Conversation, senderID: String?)
    func deleteMessage(message: Message)
    func messagesPublisher(conversationID: String) -> AnyPublisher<[Message], Never>
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
