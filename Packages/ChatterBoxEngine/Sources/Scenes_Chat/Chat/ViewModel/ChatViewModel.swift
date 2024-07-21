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
    
//    private static let messageCellModels: [MessageTextCellModel] = [
//        MessageTextCellModel(id: String(UUID().hashValue), message: "First message", isOutput: true),
//        MessageTextCellModel(id: String(UUID().hashValue), message: "Second message", isOutput: false),
//        MessageTextCellModel(id: String(UUID().hashValue), message: "Jdfjsdfd sjfkh klsajasdk aslkfhaksdjasklfh askdjasklfh ajdaskfjklaaskdjaskl adfajsdkasklfajs fkasjdkas jf", isOutput: true),
//        MessageTextCellModel(id: String(UUID().hashValue), message: "Kdskfjalksjd askjfiefjohyqwg qw duqw dqwhdqwtfra dqz drtqz cfrqacxzrtqcxcq txcqrtx cqrxc qrtx ctqxv", isOutput: false),
//        MessageTextCellModel(id: String(UUID().hashValue), message: "First message", isOutput: true),
//        MessageTextCellModel(id: String(UUID().hashValue), message: "Second message", isOutput: false),
//        MessageTextCellModel(id: String(UUID().hashValue), message: "Jdfjsdfd sjfkh klsajasdk aslkfhaksdjasklfh askdjasklfh ajdaskfjklaaskdjaskl adfajsdkasklfajs fkasjdkas jf", isOutput: true),
//        MessageTextCellModel(id: String(UUID().hashValue), message: "Kdskfjalksjd askjfiefjohyqwg qw duqw dqwhdqwtfra dqz drtqz cfrqacxzrtqcxcq txcqrtx cqrxc qrtx ctqxv", isOutput: true),
//        MessageTextCellModel(id: String(UUID().hashValue), message: "First message", isOutput: true),
//        MessageTextCellModel(id: String(UUID().hashValue), message: "Second message", isOutput: false),
//        MessageTextCellModel(id: String(UUID().hashValue), message: "Jdfjsdfd sjfkh klsajasdk aslkfhaksdjasklfh askdjasklfh ajdaskfjklaaskdjaskl adfajsdkasklfajs fkasjdkas jf", isOutput: true),
//        MessageTextCellModel(id: String(UUID().hashValue), message: "Kdskfjalksjd askjfiefjohyqwg qw duqw dqwhdqwtfra dqz drtqz cfrqacxzrtqcxcq txcqrtx cqrxc qrtx ctqxv", isOutput: false),
//        MessageTextCellModel(id: String(UUID().hashValue), message: "First message", isOutput: true),
//        MessageTextCellModel(id: String(UUID().hashValue), message: "Second message", isOutput: false),
//        MessageTextCellModel(id: String(UUID().hashValue), message: "Jdfjsdfd sjfkh klsajasdk aslkfhaksdjasklfh askdjasklfh ajdaskfjklaaskdjaskl adfajsdkasklfajs fkasjdkas jf", isOutput: true),
//        MessageTextCellModel(id: String(UUID().hashValue), message: "Kdskfjalksjd askjfiefjohyqwg qw duqw dqwhdqwtfra dqz drtqz cfrqacxzrtqcxcq txcqrtx cqrxc qrtx ctqxv", isOutput: true)
//    ]
    
    public init(
        userUseCase: UserUseCaseProtocol,
        chatUseCase: ChatUseCaseProtocol
    ) {
        self.userUseCase = userUseCase
        self.chatUseCase = chatUseCase
        
        self.state = .init(
            navigationTitle: "Chat",
            sections: [.init(type: .main, items: [])],
            composerViewModel: .init(text: "")
        )
    }
    
    // MARK: - Input
    
    func didTapSendButton() {
        let messageText = self.context.inputText
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
        self.state = Self.makeState(self.state, context: &self.context, messages: newMessages)
    }
    
    // MARK: - State Factory
    
    private static func makeState(
        _ previousState: ChatViewState?,
        context: inout ChatViewModelContext,
        messages: [Message]?
    ) -> ChatViewState {
        let rows: [ChatViewSection.RowItem]? = messages?.compactMap({ message -> ChatViewSection.RowItem? in
            switch message.type {
            case .text:
                return .textMessage(.init(id: message.id, message: message.content, isOutput: true))
            case .image:
                return .images(urls: [message.content])
            case .unknown:
                return nil
            }
        })
        
        let newRows: [ChatViewSection.RowItem]
        
        if let rows {
            newRows = rows
        } else {
            newRows = (previousState?.sections ?? []).flatMap(\.items)
        }
        
        let newSection = ChatViewSection(type: .main, items: newRows)
        
        return .init(
            navigationTitle: "Chat",
            sections: [newSection],
            composerViewModel: .init(text: context.inputText)
        )
    }
}
