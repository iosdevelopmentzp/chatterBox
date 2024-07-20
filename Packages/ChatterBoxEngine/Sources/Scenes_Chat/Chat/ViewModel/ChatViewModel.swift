//
//  ChatViewModel.swift
//  
//
//  Created by Dmytro Vorko on 20/07/2024.
//

import Foundation

private struct ChatViewModelContext {
    var inputText: String
    var newMessage: ChatViewControllerState.Message?
}

public class ChatViewModel {
    // MARK: - Properties
    
    @Published private(set) var state: ChatViewControllerState
    
    // MARK: - Private properties
    
    private var context = ChatViewModelContext(inputText: "")
    
    private static let messageCellModels: [MessageTextCellModel] = [
        MessageTextCellModel(id: String(UUID().hashValue), message: "First message", isOutput: true),
        MessageTextCellModel(id: String(UUID().hashValue), message: "Second message", isOutput: false),
        MessageTextCellModel(id: String(UUID().hashValue), message: "Jdfjsdfd sjfkh klsajasdk aslkfhaksdjasklfh askdjasklfh ajdaskfjklaaskdjaskl adfajsdkasklfajs fkasjdkas jf", isOutput: true),
        MessageTextCellModel(id: String(UUID().hashValue), message: "Kdskfjalksjd askjfiefjohyqwg qw duqw dqwhdqwtfra dqz drtqz cfrqacxzrtqcxcq txcqrtx cqrxc qrtx ctqxv", isOutput: false),
        MessageTextCellModel(id: String(UUID().hashValue), message: "First message", isOutput: true),
        MessageTextCellModel(id: String(UUID().hashValue), message: "Second message", isOutput: false),
        MessageTextCellModel(id: String(UUID().hashValue), message: "Jdfjsdfd sjfkh klsajasdk aslkfhaksdjasklfh askdjasklfh ajdaskfjklaaskdjaskl adfajsdkasklfajs fkasjdkas jf", isOutput: true),
        MessageTextCellModel(id: String(UUID().hashValue), message: "Kdskfjalksjd askjfiefjohyqwg qw duqw dqwhdqwtfra dqz drtqz cfrqacxzrtqcxcq txcqrtx cqrxc qrtx ctqxv", isOutput: true),
        MessageTextCellModel(id: String(UUID().hashValue), message: "First message", isOutput: true),
        MessageTextCellModel(id: String(UUID().hashValue), message: "Second message", isOutput: false),
        MessageTextCellModel(id: String(UUID().hashValue), message: "Jdfjsdfd sjfkh klsajasdk aslkfhaksdjasklfh askdjasklfh ajdaskfjklaaskdjaskl adfajsdkasklfajs fkasjdkas jf", isOutput: true),
        MessageTextCellModel(id: String(UUID().hashValue), message: "Kdskfjalksjd askjfiefjohyqwg qw duqw dqwhdqwtfra dqz drtqz cfrqacxzrtqcxcq txcqrtx cqrxc qrtx ctqxv", isOutput: false),
        MessageTextCellModel(id: String(UUID().hashValue), message: "First message", isOutput: true),
        MessageTextCellModel(id: String(UUID().hashValue), message: "Second message", isOutput: false),
        MessageTextCellModel(id: String(UUID().hashValue), message: "Jdfjsdfd sjfkh klsajasdk aslkfhaksdjasklfh askdjasklfh ajdaskfjklaaskdjaskl adfajsdkasklfajs fkasjdkas jf", isOutput: true),
        MessageTextCellModel(id: String(UUID().hashValue), message: "Kdskfjalksjd askjfiefjohyqwg qw duqw dqwhdqwtfra dqz drtqz cfrqacxzrtqcxcq txcqrtx cqrxc qrtx ctqxv", isOutput: true)
    ]
    
    public init() {
        self.state = .init(
            navigationTitle: "Chat",
            messages: Self.messageCellModels.map({ ChatViewControllerState.Message.text($0) }),
            composerViewModel: .init(text: "")
        )
    }
    
    // MARK: - Input
    
    func didTapSendButton() {
        let messageText = self.context.inputText
        guard !messageText.isEmpty else {
            return
        }
        context.newMessage = .text(.init(id: String(UUID().hashValue), message: messageText, isOutput: true))
        self.refreshState()
    }
    
    func didChangeText(_ text: String) {
        context.inputText = text
        refreshState()
    }
    
    // MARK: - Private
    
    private func refreshState() {
        self.state = Self.makeState(self.state, context: &self.context)
    }
    
    // MARK: - State Factory
    
    private static func makeState(
        _ previousState: ChatViewControllerState?,
        context: inout ChatViewModelContext
    ) -> ChatViewControllerState {
        let previousMessages = previousState?.messages ?? []
        let newMessages = context.newMessage.map { [$0] } ?? []
        context.newMessage = nil
        
        if !newMessages.isEmpty {
            context.inputText = ""
        }
        
        return .init(
            navigationTitle: "Chat",
            messages: newMessages + previousMessages,
            composerViewModel: .init(text: context.inputText)
        )
    }
}
