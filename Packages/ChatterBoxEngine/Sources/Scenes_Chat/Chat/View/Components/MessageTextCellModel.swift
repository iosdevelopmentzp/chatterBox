//
//  MessageTextCellModel.swift
//
//
//  Created by Dmytro Vorko on 20/07/2024.
//

import Foundation

struct MessageTextCellModel: Hashable {
    let id: String
    let message: String
    let menuInteractions: [MenuInteractionAction]
    let isOutput: Bool
}
