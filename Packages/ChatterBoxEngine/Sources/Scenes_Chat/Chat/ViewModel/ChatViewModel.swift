//
//  ChatViewModel.swift
//  
//
//  Created by Dmytro Vorko on 20/07/2024.
//

import Foundation
import UseCases
import Core
import Combine

private struct ChatViewModelContext {
    var inputText: String
}

public class ChatViewModel {
    // MARK: - Properties
    
    @Published private(set) var state: ChatViewState
    
    // MARK: - Private properties
    
    private weak var sceneDelegate: ChatSceneDelegate?
    private let userUseCase: UserUseCaseProtocol
    private let chatUseCase: ChatUseCaseProtocol
    private var context = ChatViewModelContext(inputText: "")
    
    // Ideally, this value should be injected externally. However, for this test application, we are generating a new conversation directly here if none exist.
    private lazy var conversation: Conversation = {
        let currentUser = self.userUseCase.getCurrentUser()
        var userConversations = self.chatUseCase.getConversations(userID: currentUser.id)
        
        if userConversations.isEmpty {
            self.chatUseCase.createConversation(title: "New chat", participantsID: [currentUser.id])
            userConversations = self.chatUseCase.getConversations(userID: currentUser.id)
        }
        
        guard let conversation = userConversations.first else {
            fatalError("At this point conversation must be created")
        }
        return conversation
    }()
    
    private var currentUser: User {
        self.userUseCase.getCurrentUser()
    }
    
    public init(
        userUseCase: UserUseCaseProtocol,
        chatUseCase: ChatUseCaseProtocol,
        sceneDelegate: ChatSceneDelegate?
    ) {
        self.userUseCase = userUseCase
        self.chatUseCase = chatUseCase
        self.sceneDelegate = sceneDelegate
        
        self.state = .init(
            navigationTitle: "Chat",
            sections: [.init(type: .main, items: [])],
            composerViewModel: .init(text: ""),
            containsNewMessages: false
        )
    }
    
    // MARK: - Input
    
    func didTapSendButton() {
        let messageText = self.context.inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !messageText.isEmpty else {
            return
        }
        self.context.inputText = ""
        self.refreshState()
        self.chatUseCase.saveMessage(text: messageText, conversation: conversation, senderID: self.currentUser.id)
    }
    
    func didChangeText(_ text: String) {
        context.inputText = text
        refreshState()
    }
    
    func handleMenuInteraction(action: MenuInteractionAction, messageID: String) {
        self.chatUseCase.deleteMessage(id: messageID)
    }
    
    // MARK: - Output
    
    func setupObservers(cancellations: inout Set<AnyCancellable>) {
        self.chatUseCase
            .messagesPublisher(conversationID: self.conversation.id)
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] messages in
                self?.refreshState(newMessages: messages)
            }
            .store(in: &cancellations)
    }
    
    // MARK: - Private
    
    private func refreshState(newMessages: [Message]? = nil) {
        self.state = Self.makeState(self.state, context: &self.context, messages: newMessages, conversation: conversation)
    }
    
    // MARK: - State Factory
    
    private static func makeState(
        _ previousState: ChatViewState?,
        context: inout ChatViewModelContext,
        messages: [Message]?,
        conversation: Conversation
    ) -> ChatViewState {
        let messages: [ChatViewSection.MessageItem]? = messages?.compactMap({
            message -> ChatViewSection.MessageItem? in
            let content: ChatViewSection.MessageItem.Content?
            switch message.type {
            case .text:
                content = .textMessage(.init(
                    id: message.id,
                    message: message.content,
                    isOutput: true
                ))
            case .image:
                content = .images(urls: [message.content])
            case .unknown:
                content = nil
            }
            
            guard let content else { return nil }
            
            return .init(id: message.id, content: content, menuActions: [.delete])
        })
        
        let newMessages: [ChatViewSection.MessageItem]
        let previousMessages = (previousState?.sections ?? []).flatMap(\.items)
        
        if let messages {
            newMessages = messages
        } else {
            newMessages = previousMessages
        }
        
        let newSection = ChatViewSection(type: .main, items: newMessages)
        
        return .init(
            navigationTitle: conversation.title ?? "Chat",
            sections: [newSection],
            composerViewModel: .init(text: context.inputText),
            containsNewMessages: newMessages.first != previousMessages.first
        )
    }
}
