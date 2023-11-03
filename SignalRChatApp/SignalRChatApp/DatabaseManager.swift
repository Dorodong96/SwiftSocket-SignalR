//
//  DatabaseManager.swift
//  SignalRChatApp
//
//  Created by DongKyu Kim on 2023/11/03.
//

import Foundation
import RealmSwift

enum DatabaseState {
    case create
    case insert
    case read
    case delete
    case none
    case complete
    case error
}

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let realm = try? Realm()
    private var currentDatabaseState: DatabaseState = .none
    
    private init() { }
    
    func saveMessage(message: Message) {
        guard let realm else { return }
        
        var messageObject = MessageObject(name: message.name, text: message.text)
        messageObject.roomIdDatetimes = Date().currentTimeInMilliseconds()
        
        self.currentDatabaseState = .insert
        
        do {
            try realm.write { realm.add(messageObject) }
        } catch {
            self.currentDatabaseState = .error
            return
        }
    }
    
    func loadMessages() -> [Message] {
        guard let realm else { return [] }
        
        self.currentDatabaseState = .read
        
        let messageObjects = realm.objects(MessageObject.self)
        var messages: [Message] = []
        
        messageObjects.forEach {
            messages.append(Message(name: $0.name, text: $0.text))
        }
        
        return Array(messages)
    }
}
