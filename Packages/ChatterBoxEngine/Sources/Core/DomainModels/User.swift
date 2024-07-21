//
//  User.swift
//
//
//  Created by Dmytro Vorko on 21/07/2024.
//

import Foundation

public struct User: Equatable {
    public let id: String
    public let username: String
    
    public init(id: String, username: String) {
        self.id = id
        self.username = username
    }
}
