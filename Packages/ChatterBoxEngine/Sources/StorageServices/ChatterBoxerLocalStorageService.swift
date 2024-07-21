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

public protocol ChatterBoxerLocalStorageServiceProtocol {
    func saveMessage(_ message: Message)
    func deleteMessage(_ message: Message)
    func messagesPublisher(conversationID: String) -> AnyPublisher<[Message], Never>
}

final class ChatterBoxerLocalStorageService: ChatterBoxerLocalStorageServiceProtocol {
    private let mainContext: NSManagedObjectContext
    
    init(mainContext: NSManagedObjectContext) {
        self.mainContext = mainContext
    }
    
    // MARK: - ChatterBoxerLocalStorageServiceProtocol
    
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
            
            do {
                try mainContext.save()
            } catch let error as NSError {
                // Handle any errors appropriately
                debugPrint("Error saving message: \(error), \(error.userInfo)")
            }
        }
    }
    
    func deleteMessage(_ message: Message) {
        mainContext.performAndWait {
            if let messageEntity = fetchUniqueEntityById(idKey: #keyPath(MessageEntity.messageID), id: message.id) {
                mainContext.delete(messageEntity)
                
                do {
                    try mainContext.save()
                } catch let error as NSError {
                    // Handle any errors appropriately
                    debugPrint("Error deleting message: \(error), \(error.userInfo)")
                }
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
    private func fetchUniqueEntityById<T: NSManagedObject>(idKey: String, id: String) -> T? {
        let typeName = String(describing: T.self)
        let fetchRequest = NSFetchRequest<T>(entityName: typeName)
        fetchRequest.predicate = NSPredicate(format: "\(idKey) == %@", id)
        fetchRequest.fetchLimit = 1
        do {
            let entities = try mainContext.fetch(fetchRequest)
            return entities.first
        } catch {
            debugPrint("Failed to fetch entity with ID \(id) type: \(typeName) Error: \(error)")
            return nil
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
