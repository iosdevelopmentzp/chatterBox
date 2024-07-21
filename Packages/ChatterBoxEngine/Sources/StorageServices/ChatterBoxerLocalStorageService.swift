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
            let conversationEntity = ConversationEntity(context: self.mainContext)
            conversationEntity.conversationID = conversation.id
            conversationEntity.lastMessage = conversation.lastMessage
            conversationEntity.lastMessageTime = conversation.lastMessageTime
            conversationEntity.title = conversation.title
            
            let relatedMessages: [MessageEntity] = self.fetchUniqueEntitiesBy(idKeyPath: #keyPath(MessageEntity.conversation.conversationID), id: conversation.id)
            conversationEntity.messages = Set(relatedMessages)
            
            let participants: [UserEntity] = fetchUsers(withConversationID: conversation.id)
            conversationEntity.participants = Set(participants)
            
            self.saveContext()
        }
    }
    
    func getConversations(userID: String) -> [Conversation] {
        let conversations = self.fetchConversations(withParticipantID: userID)
        return conversations.map(Conversation.init(entity:))
    }
    
    func getUser(id: String) -> User? {
        var user: User? = nil
        mainContext.performAndWait {
            guard let userEntity: UserEntity = self.fetchUniqueEntityById(idKey: #keyPath(UserEntity.userID), id: id) else {
                return
            }
            
            user = User(entity: userEntity)
        }
        return user
    }
    
    func saveUser(_ user: User) {
        mainContext.performAndWait {
            let userEntity = UserEntity(context: self.mainContext)
            userEntity.userID = user.id
            userEntity.username = user.username
            let messages: [MessageEntity] = self.fetchUniqueEntitiesBy(idKeyPath: #keyPath(MessageEntity.sender.userID), id: user.id)
            userEntity.messages = Set(messages)
            let conversations: [ConversationEntity] = self.fetchConversations(withParticipantID: user.id)
            userEntity.conversations = Set(conversations)
            self.saveContext()
        }
    }
    
    func saveMessage(_ message: Message) {
        mainContext.performAndWait {
            let messageEntity = MessageEntity(context: self.mainContext)
            messageEntity.messageID = message.id
            messageEntity.type = message.type.rawValue
            messageEntity.content = message.content
            messageEntity.timestamp = message.timestamp
            
            if let senderID = message.senderID {
                messageEntity.sender = fetchUniqueEntityById(
                    idKey: #keyPath(UserEntity.userID),
                    id: senderID
                )
            }
            
            if let conversationID = message.conversationID {
                messageEntity.conversation = fetchUniqueEntityById(
                    idKey: #keyPath(ConversationEntity.conversationID),
                    id: conversationID
                )
            }
            
            self.saveContext()
        }
    }
    
    func deleteMessage(_ message: Message) {
        mainContext.performAndWait {
            if let messageEntity = fetchUniqueEntityById(idKey: #keyPath(MessageEntity.messageID), id: message.id) {
                mainContext.delete(messageEntity)
                
                self.saveContext()
            } else {
                debugPrint("Failed to find message with ID \(message.id) to delete.")
            }
        }
    }
    
    func messagesPublisher(conversationID: String) -> AnyPublisher<[Message], Never> {
        let fetchRequest: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "conversation.conversationID == %@", conversationID)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        
        do {
            let fetchedMessages = try FetchedObjectList<MessageEntity>(fetchRequest: fetchRequest, context: mainContext)
            return fetchedMessages.objects
                .map { $0.map(Message.init) }
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
    
    private func fetchUniqueEntitiesBy<T: NSManagedObject>(idKeyPath: String, id: String) -> [T] {
        let typeName = String(describing: T.self)
        let fetchRequest = NSFetchRequest<T>(entityName: typeName)
        fetchRequest.predicate = NSPredicate(format: "%@ == %@", idKeyPath, id)
        
        do {
            let entities = try mainContext.fetch(fetchRequest)
            return entities
        } catch {
            debugPrint("Failed to fetch entity with ID \(id) type: \(typeName) Error: \(error)")
            return []
        }
    }
    
    private func fetchUniqueEntityById<T: NSManagedObject>(idKey: String, id: String) -> T? {
        let typeName = String(describing: T.self)
        let fetchRequest = NSFetchRequest<T>(entityName: typeName)
        fetchRequest.predicate = NSPredicate(format: "%@ == %@", idKey, id)
        fetchRequest.fetchLimit = 1
        do {
            let entities = try mainContext.fetch(fetchRequest)
            return entities.first
        } catch {
            debugPrint("Failed to fetch entity with ID \(id) type: \(typeName) Error: \(error)")
            return nil
        }
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
            type: entity.messageID.flatMap { MessageType(rawValue: $0) } ?? .unknown,
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
