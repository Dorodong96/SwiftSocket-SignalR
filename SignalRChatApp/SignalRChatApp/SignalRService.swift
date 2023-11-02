//
//  SignalRService.swift
//  SignalRChatApp
//
//  Created by DongKyu Kim on 2023/10/26.
//

import Foundation
import SignalRClient
import RxSwift

enum SignalRServiceEvent {
    case sendFail(Error)
    case sendComplete(Message)
    case receiveMessage(Message)
    case connectionDidFailToOpen(Error)
    case connectionDidClose(Error?)
    case connectionWillReconnect(Error)
    case connectionDidReconnect
    case none
}

public class SignalRService {
    
    var publishEvent = PublishSubject<SignalRServiceEvent>()
    private var connection: HubConnection
    
    public init(url: URL) {
        print("SignalRService Init")
        
        connection = HubConnectionBuilder(url: url)
            .withAutoReconnect()
            .build()
        
        connection.delegate = self
        
        connection.on(method: "NewMessage", callback: { (message: Message) in
            self.handleMessage(message)
        })
        
        connection.start()
    }
    
    deinit {
        print("SignalRService Deinit")
    }
    
    func sendMessage(message: Message) {
        print("Message Send: \(message)")
        connection.send(method: "Broadcast", message) { error in
            if let error {
                self.publishEvent.onNext(.sendFail(error))
            } else {
                self.publishEvent.onNext(.sendComplete(message))
            }
        }
    }
    
    private func handleMessage(_ message: Message) {
        publishEvent.onNext(.receiveMessage(message))
    }
    
}

extension SignalRService: HubConnectionDelegate {
    public func connectionDidOpen(hubConnection: SignalRClient.HubConnection) {
        
    }
    
    public func connectionDidFailToOpen(error: Error) {
        publishEvent.onNext(.connectionDidFailToOpen(error))
    }
    
    public func connectionDidClose(error: Error?) {
        publishEvent.onNext(.connectionDidClose(error))
    }
    
    public func connectionWillReconnect(error: Error) {
        publishEvent.onNext(.connectionWillReconnect(error))
    }
    
    public func connectionDidReconnect() {
        publishEvent.onNext(.connectionDidReconnect)
    }
}
