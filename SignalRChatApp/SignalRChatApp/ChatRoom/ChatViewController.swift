//
//  ChatViewController.swift
//  SignalRChatApp
//
//  Created by DongKyu Kim on 2023/10/31.
//

import UIKit
import SnapKit

import RxCocoa
import ReactorKit

class ChatViewController: UIViewController, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    private lazy var chatTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: MessageTableViewCell.reuseIdentifier)
        return tableView
    }()
    
    private lazy var messageTextView: UITextView = {
        let textView = self.accessoryView.textView
        textView.inputAccessoryView = self.accessoryView
        return textView
    }()
    
    private lazy var accessoryView: ChatInputAccessoryView = {
        let accessoryView = ChatInputAccessoryView(frame: .init(x: 0, y: 0, width: view.frame.width, height: 60))
        return accessoryView
    }()
    
    override var inputAccessoryView: UIView? {
        get { return accessoryView }
    }
    
    private var alertController: UIAlertController?
    private var saveAction: UIAlertAction?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setViewLayout()
        self.setChatInputAccesoryViewLayout()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardDown))
        self.view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        self.removeKeyboardObserver()
    }
    
    
    func bind(reactor: ChatViewModel) {
        
        // action (View -> Reactor)
        // Reactor Action의 sendMessage case 타입으로 매핑해서
        // reactor의 Action에 바인딩
        
        accessoryView.sendButton.rx.tap
            .withLatestFrom(messageTextView.rx.text)
            .filter { $0 != nil && !$0!.isEmpty }
            .map { Reactor.Action.tapSendButton($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // Data Binding
        reactor.chatMessagesObservable
            .observe(on: MainScheduler.instance)
            .filter { !$0.isEmpty }
            .bind(to: chatTableView.rx.items(cellIdentifier: MessageTableViewCell.reuseIdentifier, cellType: MessageTableViewCell.self)) {index, message, cell in
                
                cell.config(name: message.name, message: message.text)
            }
            .disposed(by: disposeBag)
        
        reactor.chatMessagesObservable
            .observe(on: MainScheduler.instance)
            .filter { !$0.isEmpty }
            .bind(onNext: { messages in
                let indexPath = IndexPath(row: messages.count - 1, section: 0)
                self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                self.messageTextView.text = ""
            })
            .disposed(by: disposeBag)
        
        // State (Reactor -> View)
        reactor.state.map { $0.receivedMessage }
            .withUnretained(self)
            .subscribe { weakSelf, message in
                guard let message else { return }
                print("서버 메시지 갱신: \(message)")
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.hubConnectionState }
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe { weakSelf, state in
                weakSelf.showPopup(state)
            }
            .disposed(by: disposeBag)
    }
    
    
    private func addMessage(index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        
        self.messageTextView.text = ""
    }
    
    
    private func showPopup(_ state: HubConnectionState) {
        
        switch state {
        case .sendError:
            alertController = UIAlertController(title: "전송 실패", message: "Connection Error", preferredStyle: .alert)
            saveAction = UIAlertAction(title: "OK", style: .default)
            
        case .sendComplete:
            print("전송 완료")
            return
            
        case .connectionError:
            alertController = UIAlertController(title: "에러", message: "Connection Error", preferredStyle: .alert)
            saveAction = UIAlertAction(title: "OK", style: .default)
            
        case .reconnect:
            alertController = UIAlertController(title: "Connection Lost", message: "Reconnecting...", preferredStyle: .alert)
            
            guard let alertController else { return }
            present(alertController, animated: true, completion: nil)
            return
            
        case .none:
            alertController?.dismiss(animated: true)
            return
        }
        
        guard let alertController else { return }
        guard let saveAction else { return }
        
        alertController.addAction(saveAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    private func setViewLayout() {
        self.view.addSubview(chatTableView)
        
        chatTableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    
    // AccessoryView(입력창) 레이아웃 재배치
    private func setChatInputAccesoryViewLayout() {
        self.view.addSubview(accessoryView)
        
        accessoryView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(60)
        }
    }
    
    @objc func hideKeyboardDown(_ sender: Any) {
        self.setChatInputAccesoryViewLayout()
        self.accessoryView.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRect = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRect.height
            
            if keyboardHeight > 0 {
                self.chatTableView.setContentOffset(CGPoint(x: self.chatTableView.bounds.minX, y: self.chatTableView.bounds.minY), animated: false)
            }
            
            self.chatTableView.contentInset.bottom = keyboardHeight
            let lastSection = chatTableView.numberOfSections - 1
            let lastRow = chatTableView.numberOfRows(inSection: lastSection) - 1

            if lastSection >= 0 && lastRow >= 0 {
                let lastIndexPath = IndexPath(row: lastRow, section: lastSection)

                // Scroll the table view to the last row with animation
                chatTableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        // 키보드 사라질 때 contentInset 및 scrollIndicatorInsets 초기화
        chatTableView.contentInset.bottom = 60
        chatTableView.scrollIndicatorInsets = .zero
    }
}
