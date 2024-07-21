//
//  UserUseCase.swift
//
//
//  Created by Dmytro Vorko on 21/07/2024.
//

import Foundation
import Core
import StorageServices

public protocol UserUseCaseProtocol {
    func createCurrentUser(username: String)
    func getCurrentUser() -> User?
    func createUser(userName: String)
}

final class UserUseCase: UserUseCaseProtocol {
    private let storage: ChatterBoxerLocalStorageServiceProtocol
    
    init(storage: ChatterBoxerLocalStorageServiceProtocol) {
        self.storage = storage
    }
    
    // MARK: - UserUseCaseProtocol
    
    func createCurrentUser(username: String) {
        let id = String(UUID().hashValue)
        // TODO: - keep current user ID to UserDefaults
        let user = User(id: id, username: username)
        self.storage.saveUser(user)
    }
    
    func getCurrentUser() -> User? {
        #warning("Implement correct current user ID handling")
        // TODO: - get current user id in UserDefaults
        let id = "currentUserID"
        return storage.getUser(id: id)
    }
    
    func createUser(userName: String) {
        let id = String(UUID().hashValue)
        let user = User(id: id, username: userName)
        self.storage.saveUser(user)
    }
}
