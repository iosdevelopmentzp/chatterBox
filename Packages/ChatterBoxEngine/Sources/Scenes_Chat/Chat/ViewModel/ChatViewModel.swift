//
//  ChatViewModel.swift
//  
//
//  Created by Dmytro Vorko on 20/07/2024.
//

import Foundation
import UseCases

private struct ChatViewModelContext {
    var inputText: String
    var newRowItem: ChatViewSection.RowItem?
}

public class ChatViewModel {
    // MARK: - Properties
    
    @Published private(set) var state: ChatViewState
    
    // MARK: - Private properties
    
    private let userUseCase: UserUseCaseProtocol
    private let chatUseCase: ChatUseCaseProtocol
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
    
    public init(
        userUseCase: UserUseCaseProtocol,
        chatUseCase: ChatUseCaseProtocol
    ) {
        self.userUseCase = userUseCase
        self.chatUseCase = chatUseCase
        
        let rowItems = Self.messageCellModels.map({ ChatViewSection.RowItem.textMessage($0) })
        self.state = .init(
            navigationTitle: "Chat",
            sections: [.init(type: .main, items: rowItems)],
            composerViewModel: .init(text: "")
        )
    }
    
    // MARK: - Input
    
    func didTapSendButton() {
        let messageText = self.context.inputText
        guard !messageText.isEmpty else {
            return
        }
        context.newRowItem = .textMessage(
            .init(id: String(UUID().hashValue), message: messageText, isOutput: true)
        )
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
        _ previousState: ChatViewState?,
        context: inout ChatViewModelContext
    ) -> ChatViewState {
        let previousRows = (previousState?.sections ?? []).flatMap(\.items)
        let newRows = context.newRowItem.map { [$0] } ?? []
        context.newRowItem = nil
        
        if !newRows.isEmpty {
            context.inputText = ""
        }
        
        let newSection = ChatViewSection(type: .main, items: newRows + previousRows)
        
        return .init(
            navigationTitle: "Chat",
            sections: [newSection],
            composerViewModel: .init(text: context.inputText)
        )
    }
}
