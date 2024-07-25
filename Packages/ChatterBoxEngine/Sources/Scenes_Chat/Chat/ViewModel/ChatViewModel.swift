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
import ImageCacheKit

private struct ChatViewModelContext {
    var inputText: String
}

public class ChatViewModel {
    // MARK: - Properties
    
    @Published private(set) var state: ChatViewState
    let imageCacher: ImageCacherProtocol
    
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
            let companion = self.userUseCase.generateUser()
            self.chatUseCase.createConversation(title: "New chat", participantsID: [currentUser.id, companion.id])
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
        imageCacher: ImageCacherProtocol,
        sceneDelegate: ChatSceneDelegate?
    ) {
        self.userUseCase = userUseCase
        self.chatUseCase = chatUseCase
        self.imageCacher = imageCacher
        self.sceneDelegate = sceneDelegate
        
        self.state = .init(
            navigationTitle: "Chat",
            sections: [.init(type: .main, items: [])],
            composerViewModel: .init(text: ""),
            containsNewMessages: false
        )
    }
    
    // MARK: - Input
    
    func didTapGenerateMessage(input: Bool) {
        let inputUserId = self.conversation.participantsID.first(where: { $0 != self.currentUser.id })
        let senderId = input ? inputUserId : self.currentUser.id
        
        let randomMessage = Self.fakeMessages.randomElement() ?? ""
        self.chatUseCase.saveMessage(
            content: .init(text: randomMessage, imageURLs: nil),
            conversation: self.conversation,
            senderID: senderId
        )
    }
    
    func didTapSendButton() {
        let messageText = self.context.inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !messageText.isEmpty else {
            return
        }
        self.context.inputText = ""
        self.refreshState()
        
        let content = Message.Content(text: messageText, imageURLs: nil)
        self.chatUseCase.saveMessage(content: content, conversation: conversation, senderID: self.currentUser.id)
    }
    
    func didTapAttachButton() {
        self.sceneDelegate?.didTapAttachImages(completion: { [weak self] urlImages in
            guard !urlImages.isEmpty, let self else { return }
            self.chatUseCase.saveMessage(
                content: .init(text: nil, imageURLs: urlImages),
                conversation: self.conversation,
                senderID: self.currentUser.id
            )
        })
    }
    
    func didChangeText(_ text: String) {
        context.inputText = text
        refreshState()
    }
    
    func handleMenuInteraction(action: MenuInteractionAction, messageID: String) {
        self.chatUseCase.deleteMessage(id: messageID)
    }
    
    func handleImageMenuInteraction(action: MenuInteractionAction, messageID: String, imageIndex: Int) {
        switch action {
        case .delete:
            
            guard let message = self.conversation.messages.first(where: { $0.id == messageID }) else {
                return
            }
            let imageURL = (message.content.imageURLs?[safe: imageIndex]).flatMap(URL.init(string:))
            if let imageURL {
                Task(priority: .background) {
                    try await self.imageCacher.deleteImage(from: imageURL)
                }
            }
            
            self.chatUseCase.updateMessage(message, change: .deleteImage(index: imageIndex))
        }
    }
    
    // MARK: - Output
    
    func setupObservers(cancellations: inout Set<AnyCancellable>) {
        self.chatUseCase
            .conversationPublisher(conversationID: self.conversation.id)
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] conversation in
                self?.conversation = conversation
                self?.refreshState(conversation: conversation)
            }
            .store(in: &cancellations)
    }
    
    // MARK: - Private
    
    private func refreshState(conversation: Conversation? = nil) {
        self.state = Self.makeState(
            self.state,
            context: &self.context,
            conversation: conversation,
            currentUser: self.currentUser
        )
    }
    
    // MARK: - State Factory
    
    private static func makeState(
        _ previousState: ChatViewState?,
        context: inout ChatViewModelContext,
        conversation: Conversation?,
        currentUser: User
    ) -> ChatViewState {
        /* 1. try to map the original messages */
        let messages = conversation?.messages.compactMap({
            let isOutput = $0.senderID == currentUser.id
            return ChatViewSection.MessageItem(message: $0, isOutput: isOutput, actions: [.delete])
        })
        
        let newMessages: [ChatViewSection.MessageItem]
        
        /* 2. Get current state messages */
        let previousMessages = (previousState?.sections ?? []).flatMap(\.items)
        
        /* 3. Take original messages If we got it (probably something has been changed)... */
        if let messages {
            newMessages = messages
        } else {
            /* 4. ...otherwise reuse the existed ones */
            newMessages = previousMessages
        }
        
        /* 5. New sections */
        let newSection = ChatViewSection(type: .main, items: newMessages)
        
        return .init(
            navigationTitle: previousState?.navigationTitle ?? conversation?.title ?? "Chat",
            sections: [newSection],
            composerViewModel: .init(text: context.inputText),
            containsNewMessages: newMessages.first != previousMessages.first
        )
    }
}

private extension ChatViewSection.MessageItem {
    init?(message: Message, isOutput: Bool, actions: [MenuInteractionAction]) {
        let content: ChatViewSection.MessageItem.Content?
        switch message.type {
        case .text:
            content = .textMessage(.init(
                id: message.id,
                message: message.content.text ?? "",
                menuInteractions: actions,
                isOutput: isOutput
            ))
        case .image:
            content = .images(model: .init(
                id: message.id,
                imageURLs: message.content.imageURLs ?? [],
                menuInteractions: actions,
                isOutput: isOutput
            ))
        case .unknown:
            content = nil
        }
        
        guard let content else {
            return nil
        }
        
        self = .init(id: message.id, content: content)
    }
}

extension ChatViewModel {
    static let fakeMessages = [
        "Hey! How's everything going? 😊",
        "I was thinking about our last conversation and I have some more ideas. 🤔",
        "Can you send me the details by tomorrow? 📅",
        "Absolutely loved the photos from the trip! Thanks for sharing. 🌟",
        "What's the plan for the weekend? Any thoughts on going hiking? 🌲",
        "Remember to bring the documents for the meeting. 📄",
        "Just saw this funny video and thought of you, I'll send it over! 😂",
        "Can we reschedule our appointment to next week? 🗓️",
        "I need some advice on a project I'm working on, got a minute? 🛠️",
        "Happy Birthday! Hope you have a fantastic day filled with joy and laughter. 🎉",
        "Did you hear about the new restaurant opening downtown? We should check it out. 🍴",
        "It was great seeing you at the event last night, let's catch up soon. 🥂",
        "Are you free for a quick call this afternoon? 📞",
        "I'm running late but I'll be there as soon as I can. 🏃‍♂️",
        "Can you help me with the setup for the new software? 💻",
        "Just a reminder to update your app for the latest features and improvements. 🔄",
        "Let's get coffee next time you're in town. ☕",
        "I've attached the file you asked for in the email. 📎",
        "How's the family doing? Hope everyone is well. 🏡",
        "Looking forward to our meeting tomorrow. Let's make it productive! 📈",
        "Hey there! Just wanted to check in and see how everything's going with the new project. I heard there were some challenges with the supplier.",
        "Can you believe how fast time is flying? Feels like just yesterday we were planning our summer vacations, and now it's almost winter!",
        "I've been thinking about our discussion on digital marketing strategies, and I believe integrating AI for better analytics might give us an edge over competitors.",
        "Just a heads up that I'll need those reports by Monday. Please ensure they include the updated figures and projections for next quarter.",
        "Thanks again for helping out with the event planning. Your input was invaluable, and I think it's going to be a fantastic gathering!",
        "If you're free this weekend, would you want to join me and a few friends for a small get-together? We're planning to grill and chill in the backyard.",
        "I was reading about investment opportunities in emerging technologies, and I came across some interesting points that might pique your interest.",
        "Can we schedule a meeting to discuss the development progress? There are a few issues that need immediate attention to ensure we stay on track.",
        "I appreciate your feedback on my presentation yesterday. I'll incorporate your suggestions to improve the clarity and impact of the final version.",
        "Could you send me the contact details of the consultant we discussed last week? I need some expert advice on a legal matter concerning our startup.",
        "Hope everything is well with you and the family. Let's plan a catch-up soon! Maybe a weekend brunch or a day at the park?",
        "I'm organizing a community cleanup day and would love for you and your family to join us. It's a great way to give back and make our neighborhood a better place!",
        "Remember to double-check the attachments before sending out the client proposal. We can't afford any mistakes at this stage of the negotiation.",
        "I was reflecting on your suggestions for improving team productivity, and I'd like to discuss implementing a trial period for the flexible work hours you mentioned.",
        "As we prepare for the upcoming audit, please review all relevant accounts and transactions from the past year to ensure everything is accurate and compliant.",
        
    ]
}
