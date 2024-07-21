//
//  ChatterBoxerLocalStorageService.swift
//
//
//  Created by Dmytro Vorko on 21/07/2024.
//

import Foundation
import CoreData
import Core
import Combine
import CoreStorageService

public protocol ChatterBoxerLocalStorageServiceProtocol {
    func saveConversation(_ conversation: Conversation)
    func getConversations(userID: String) -> [Conversation]
    
    func getUser(id: String) -> User?
    func saveUser(_ user: User)
    
    func saveMessage(_ message: Message)
    func deleteMessage(_ message: Message)
    func messagesPublisher(conversationID: String) -> AnyPublisher<[Message], Never>
}

final class ChatterBoxerLocalStorageService: ChatterBoxerLocalStorageServiceProtocol {
    private let storageService: ChatterBoxCoreStorageServiceProtocol
    
    private var mainContext: NSManagedObjectContext {
        storageService.viewContext
    }
    
    init(storageService: ChatterBoxCoreStorageServiceProtocol) {
        self.storageService = storageService
    }
    
    // MARK: - ChatterBoxerLocalStorageServiceProtocol
    
    func saveConversation(_ conversation: Conversation) {
        mainContext.performAndWait {
            do {
                let conversationEntity = ConversationEntity(context: self.mainContext)
                conversationEntity.conversationID = conversation.id
                conversationEntity.lastMessage = conversation.lastMessage
                conversationEntity.lastMessageTime = conversation.lastMessageTime
                conversationEntity.title = conversation.title
                
                let relatedMessages: [MessageEntity] = try self.fetchEntities(by: #keyPath(MessageEntity.conversation.conversationID), withID: conversation.id)
                conversationEntity.messages = Set(relatedMessages)
                
                let participants: [UserEntity] = try fetchEntities(by: #keyPath(UserEntity.userID), withIDs: conversation.participantsID)
                conversationEntity.participants = Set(participants)
                
                self.saveContext()
            } catch {
                debugPrint("Failed save conversation: \(error.localizedDescription)")
            }
            
        }
    }
    
    func getConversations(userID: String) -> [Conversation] {
        let conversations = self.fetchConversations(withParticipantID: userID)
        return conversations.map(Conversation.init(entity:))
    }
    
    func getUser(id: String) -> User? {
        var user: User? = nil
        mainContext.performAndWait {
            do {
                guard let userEntity: UserEntity = try self.fetchEntity(by: #keyPath(UserEntity.userID), withID: id) else {
                    return
                }
                
                user = User(entity: userEntity)
            } catch {
                debugPrint("Failed get user id: \(id). Error: \(error)")
            }
            
        }
        return user
    }
    
    func saveUser(_ user: User) {
        mainContext.performAndWait {
            do {
                let userEntity = UserEntity(context: self.mainContext)
                userEntity.userID = user.id
                userEntity.username = user.username
                let messages: [MessageEntity] =  try self.fetchEntities(by: #keyPath(MessageEntity.sender.userID), withID: user.id)
                userEntity.messages = Set(messages)
                let conversations: [ConversationEntity] = self.fetchConversations(withParticipantID: user.id)
                userEntity.conversations = Set(conversations)
                self.saveContext()
            } catch {
                debugPrint("Failed save user: \(error.localizedDescription)")
            }
        }
    }
    
    func saveMessage(_ message: Message) {
        mainContext.performAndWait {
            do {
                let messageEntity = MessageEntity(context: self.mainContext)
                messageEntity.messageID = message.id
                messageEntity.type = message.type.rawValue
                messageEntity.content = message.content
                messageEntity.timestamp = message.timestamp
                
                if let senderID = message.senderID {
                    messageEntity.sender = try self.fetchEntity(by: #keyPath(UserEntity.userID), withID: senderID)
                }
                
                if let conversationID = message.conversationID {
                    messageEntity.conversation =  try self.fetchEntity(by: #keyPath(ConversationEntity.conversationID), withID: conversationID)
                }
                
                self.saveContext()
            } catch {
                debugPrint("Failed save message: \(error.localizedDescription)")
            }
            
        }
    }
    
    func deleteMessage(_ message: Message) {
        mainContext.performAndWait {
            do {
                if let messageEntity = try fetchEntity(by: #keyPath(MessageEntity.messageID), withID: message.id) {
                    mainContext.delete(messageEntity)
                    
                    self.saveContext()
                } else {
                    debugPrint("Failed delete message action. Message was not find. message with ID \(message.id) ")
                }
            } catch {
                debugPrint("Failed to find message with ID \(message.id) to delete.")
            }
        }
    }
    
    func messagesPublisher(conversationID: String) -> AnyPublisher<[Message], Never> {
        let fetchRequest: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(MessageEntity.conversation.conversationID), conversationID)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            let fetchedMessages = try FetchedObjectList<MessageEntity>(fetchRequest: fetchRequest, context: mainContext)
            return fetchedMessages.objects
                .map {
                    _ = fetchedMessages
                    return $0.map(Message.init)
                }
                .eraseToAnyPublisher()
        } catch {
            // Handle Error appropriately
            debugPrint("Failed to publish messages conversationID: \(conversationID). Error: \(error)")
            return Just([]).eraseToAnyPublisher()
        }
    }
}

// MARK: - Private

extension ChatterBoxerLocalStorageService {
    private func fetchUsers(withConversationID conversationID: String) -> [UserEntity] {
        let request = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "ANY conversations.conversationID == %@", conversationID)
        
        do {
            let entities = try mainContext.fetch(request)
            return entities
        } catch {
            debugPrint("Failed to fetch users with conversationID \(conversationID). Error: \(error)")
            return []
        }
    }
    
    private func fetchConversations(withParticipantID participantID: String) -> [ConversationEntity] {
        let request = ConversationEntity.fetchRequest()
        request.predicate = NSPredicate(format: "ANY participants.userID == %@", participantID)
        
        do {
            let entities = try mainContext.fetch(request)
            return entities
        } catch {
            debugPrint("Failed to fetch conversations with participant ID \(participantID). Error: \(error)")
            return []
        }
    }
    
    private func fetchEntities<T: NSManagedObject>(by keyPath: String, withID id: String) throws -> [T] {
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
        fetchRequest.predicate = NSPredicate(format: "%K == %@", keyPath, id)
        return try mainContext.fetch(fetchRequest)
    }

    private func fetchEntities<T: NSManagedObject>(by keyPath: String, withIDs ids: [String]) throws -> [T] {
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
        fetchRequest.predicate = NSPredicate(format: "%K IN %@", keyPath, ids)
        return try mainContext.fetch(fetchRequest)
    }
    
    private func fetchEntity<T: NSManagedObject>(by keyPath: String, withID id: String) throws -> T? {
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
        fetchRequest.predicate = NSPredicate(format: "%K == %@", keyPath, id)
        fetchRequest.fetchLimit = 1
        return try mainContext.fetch(fetchRequest).first
    }
    
    private func saveContext() {
        guard self.mainContext.hasChanges else { return }
        do {
            try mainContext.save()
        } catch let error as NSError {
            // Handle any errors appropriately
            debugPrint("Error saving message: \(error), \(error.userInfo)")
        }
    }
}

private extension Message {
    init(entity: MessageEntity) {
        self = .init(
            id: entity.messageID ?? "",
            type: entity.type.flatMap { MessageType(rawValue: $0) } ?? .unknown,
            conversationID: entity.conversation?.conversationID,
            senderID: entity.sender?.userID,
            content: entity.content ?? "",
            timestamp: entity.timestamp ?? Date()
        )
    }
}

private extension User {
    init(entity: UserEntity) {
        self = .init(id: entity.userID ?? "", username: entity.username ?? "")
    }
}

private extension Conversation {
    init(entity: ConversationEntity) {
        self = .init(
            id: entity.conversationID ?? "",
            participantsID: entity.participants?.compactMap { $0.userID } ?? [],
            messages: entity.messages?.map { Message(entity: $0) } ?? [],
            title: entity.title,
            lastMessage: entity.lastMessage,
            lastMessageTime: entity.lastMessageTime
        )
    }
}
