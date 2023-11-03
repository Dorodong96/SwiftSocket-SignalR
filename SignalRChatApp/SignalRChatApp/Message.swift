//
//  Message.swift
//  SignalRChatApp
//
//  Created by DongKyu Kim on 2023/10/26.
//

import Foundation
import RealmSwift

struct Message: Hashable, Codable {
    let name: String
    let text: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(text)
    }
}

class MessageObject: Object, Codable {
    @Persisted(primaryKey: true) var roomIdDatetimes: String
    @Persisted var name: String = ""
    @Persisted var text: String = ""
    
    convenience init(name: String, text: String) {
        self.init()
        self.name = name
        self.text = text
    }
    
}
