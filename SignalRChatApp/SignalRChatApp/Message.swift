//
//  Message.swift
//  SignalRChatApp
//
//  Created by DongKyu Kim on 2023/10/26.
//

import Foundation

struct Message: Hashable, Codable {
    let name: String
    let text: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(text)
    }
}
