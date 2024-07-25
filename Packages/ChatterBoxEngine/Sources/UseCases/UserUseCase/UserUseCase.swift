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
    func getCurrentUser() -> User
    func createUser(userName: String)
    func generateUser() -> User
}

final class UserUseCase: UserUseCaseProtocol {
    private let storage: ChatterBoxerLocalStorageServiceProtocol
    // Currently using a direct reference to UserDefaults for simplicity. For better modularity and testability, consider implementing a dedicated UserDefaultsStorageService.
    private let userDefaults = UserDefaults(suiteName: "ChatterBox")
    
    init(storage: ChatterBoxerLocalStorageServiceProtocol) {
        self.storage = storage
    }
    
    // MARK: - UserUseCaseProtocol
    
    func getCurrentUser() -> User {
        let user: User
        if let currentUserID = self.userDefaults?.currentUserID, let storageUser = storage.getUser(id: currentUserID) {
            user = storageUser
        } else {
            let id = UUID().uuidString
            user = User(id: id, username: "User_\(id)")
            self.userDefaults?.currentUserID = id
            self.storage.saveUser(user)
        }
        return user
    }
    
    func generateUser() -> User {
        let id = UUID().uuidString
        let user = User(id: id, username: "User_\(id)")
        self.storage.saveUser(user)
        return user
    }
    
    func createUser(userName: String) {
        let id = UUID().uuidString
        let user = User(id: id, username: userName)
        self.storage.saveUser(user)
    }
}

private extension UserDefaults {
    var currentUserID: String? {
        get {
            self.string(forKey: "currentUserID")
        }
        
        set {
            self.setValue(newValue, forKey: "currentUserID")
        }
    }
}
