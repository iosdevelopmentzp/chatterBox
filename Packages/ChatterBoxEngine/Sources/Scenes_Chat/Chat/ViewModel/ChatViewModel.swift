//
//  ChatViewModel.swift
//  
//
//  Created by Dmytro Vorko on 20/07/2024.
//

import Foundation

public class ChatViewModel {
    @Published var state: ChatViewControllerState
    
    private static let messageCellModels = [
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
}
