//
//  ChatViewModel.swift
//  SignalRChatApp
//
//  Created by DongKyu Kim on 2023/10/31.
//

import Foundation
import ReactorKit
import RxSwift

public enum HubConnectionState {
    case none
    case sendError
    case sendComplete
    case connectionError
    case reconnect
}

class ChatViewModel: Reactor {
    
    typealias ChatMessages = [Message]
    // 💥 추후 DB 연결 버전으로 수정
    private var chatMessages: ChatMessages = []
    
    var signalRService: SignalRService
    private lazy var chatMessageSubject = PublishSubject<ChatMessages>()
    lazy var chatMessagesObservable: Observable<ChatMessages> = chatMessageSubject.asObservable()
    
    enum Action {
        case sendMessage(Message)
    }
    
    enum Mutation {
        case receiveMessage(Message)
        case mutateHubConnection(HubConnectionState)
    }
    
    struct State {
        var receivedMessage: Message?
        var hubConnectionState: HubConnectionState = .none
    }
    
    let initialState: State = State()
    
    init(domainURL: String) {
        self.signalRService = .init(url: URL(string: domainURL)!)
    }
}

extension ChatViewModel {
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .sendMessage(let message):
            print(message)
            self.signalRService.sendMessage(message: message)
            return .empty()
        }
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        
        let eventMutation = signalRService.publishEvent.flatMap { event -> Observable<Mutation> in
            switch event {
                
            case .sendFail(let error):
                print("\(error.localizedDescription)")
                return .just(.mutateHubConnection(.sendError))
                
            case .sendComplete(let message):
                print("Sended Message: \(message)")
                self.chatMessageSubject.onNext(self.chatMessages)
                return .just(.mutateHubConnection(.sendComplete))
                
            case .receiveMessage(let message):
                self.chatMessages.append(message)
                self.chatMessageSubject.onNext(self.chatMessages)
                return .just(.receiveMessage(message))
                
            case .connectionDidFailToOpen(let error):
                print("\(error.localizedDescription)")
                return .just(.mutateHubConnection(.connectionError))
                
            case .connectionDidClose(let optionalError):
                if let error = optionalError {
                    print("\(error.localizedDescription)")
                    return .just(.mutateHubConnection(.connectionError))
                } else {
                    return .empty()
                }
                
            case .connectionWillReconnect(let error):
                print("\(error.localizedDescription)")
                return .just(.mutateHubConnection(.reconnect))
                
            case .connectionDidReconnect:
                return .just(.mutateHubConnection(.none))
                
            default:
                return .empty()
            }
        }
        
        return Observable.merge(eventMutation)
    }
    
    // Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        
        var state = state
        
        switch mutation {

        case .receiveMessage(let message):
            state.receivedMessage = message
            
        case .mutateHubConnection(let hubConnectionState):
            state.hubConnectionState = hubConnectionState
        }
        
        return state
    }
}
