//
//  SignalRService.swift
//  SignalRChatApp
//
//  Created by DongKyu Kim on 2023/10/26.
//

import Foundation
import SignalRClient

public class SignalRService {
    private var connection: HubConnection
    
    public init(url: URL) {
        connection = HubConnectionBuilder(url: url).withLogging(minLogLevel: .error).build()
        connection.on(method: "MessageReceived", callback: { (user: String, message: String) in
            self.handleMessage(message, from: user)
        })
        
        connection.start()
    }
    
    private func handleMessage(_ message: String, from user: String) {
        // Do something with the message.
    }
}
