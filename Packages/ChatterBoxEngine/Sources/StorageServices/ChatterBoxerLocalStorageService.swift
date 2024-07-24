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
    func deleteMessage(id: String)
    func conversationPublisher(conversationID: String) -> AnyPublisher<Conversation, Never>
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
                
                let participants: [UserEntity] = try fetchEntities(type: UserEntity.self, where: #keyPath(UserEntity.userID), isIn: conversation.participantsID)
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
                guard let userEntity = try self.fetchEntity(type: UserEntity.self, where: #keyPath(UserEntity.userID), equal: id) else {
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
                let content = MessageContentEntity(context: self.mainContext)
                content.text = message.content.text
                let imagesArray = message.content.imageURLs?.map { urlString -> ImageEntity in
                    let imageEntity = ImageEntity(context: self.mainContext)
                    imageEntity.url = urlString
                    return imageEntity
                }
                content.images = imagesArray.map { Set($0) }
                messageEntity.content = content
                messageEntity.timestamp = message.timestamp
                
                if let senderID = message.senderID {
                    messageEntity.sender = try self.fetchEntity(type: UserEntity.self, where: #keyPath(UserEntity.userID), equal: senderID)
                }
                
                if let conversationID = message.conversationID {
                    messageEntity.conversation =  try self.fetchEntity(type: ConversationEntity.self, where: #keyPath(ConversationEntity.conversationID), equal: conversationID)
                }
                
                self.saveContext()
            } catch {
                debugPrint("Failed save message: \(error.localizedDescription)")
            }
            
        }
    }
    
    func deleteMessage(id: String) {
        mainContext.performAndWait {
            do {
                if let messageEntity = try fetchEntity(type: MessageEntity.self, where: #keyPath(MessageEntity.messageID), equal: id) {
                    mainContext.delete(messageEntity)
                    
                    self.saveContext()
                } else {
                    debugPrint("Failed delete message action. Message was not find. message with ID \(id) ")
                }
            } catch {
                debugPrint("Failed to find message with ID \(id) to delete.")
            }
        }
    }
    
    func conversationPublisher(conversationID: String) -> AnyPublisher<Conversation, Never> {
        let fetchRequest: NSFetchRequest<ConversationEntity> = ConversationEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(ConversationEntity.conversationID), conversationID)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ConversationEntity.conversationID), ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            let fetchedConversations = try FetchedObjectList<ConversationEntity>(fetchRequest: fetchRequest, context: mainContext)
            return fetchedConversations
                .objects
                .eraseToAnyPublisher()
                .map { $0.first }
                .compactMap { $0 }
                .map {
                    _ = fetchedConversations
                    return Conversation(entity: $0)
                }
                .eraseToAnyPublisher()
        } catch {
            // Handle Error appropriately
            debugPrint("Failed to publish messages conversationID: \(conversationID). Error: \(error)")
            return Empty(completeImmediately: true).eraseToAnyPublisher()
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

    private func fetchEntities<T: NSManagedObject>(type: T.Type, where keyPath: String, isIn values: [String]) throws -> [T] {
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
        fetchRequest.predicate = NSPredicate(format: "%K IN %@", keyPath, values)
        return try mainContext.fetch(fetchRequest)
    }
    
    private func fetchEntity<T: NSManagedObject>(type: T.Type, where keyPath: String, equal value: String) throws -> T? {
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
        fetchRequest.predicate = NSPredicate(format: "%K == %@", keyPath, value)
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
        let content = Message.Content(
            text: entity.content?.text,
            imageURLs: entity.content?.images?.compactMap { $0.url }
        )
        
        self = .init(
            id: entity.messageID ?? "",
            type: entity.type.flatMap { MessageType(rawValue: $0) } ?? .unknown,
            conversationID: entity.conversation?.conversationID,
            senderID: entity.sender?.userID,
            content: content,
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
        let messages = (entity.messages?.map { Message(entity: $0) } ?? []).sorted(by: {
            $0.timestamp > $1.timestamp
        })
        self = .init(
            id: entity.conversationID ?? "",
            participantsID: entity.participants?.compactMap { $0.userID } ?? [],
            messages: messages,
            title: entity.title,
            lastMessage: entity.lastMessage,
            lastMessageTime: entity.lastMessageTime
        )
    }
}
