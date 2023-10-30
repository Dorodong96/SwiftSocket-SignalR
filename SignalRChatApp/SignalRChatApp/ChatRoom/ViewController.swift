//
//  ViewController.swift
//  SignalRChatApp
//
//  Created by DongKyu Kim on 2023/10/26.
//

import UIKit
import SignalRClient

class ViewController: UIViewController {

    enum PopupKind {
        case none
        case name
        case error
        case errorRestart
        case reconnect
    }
    
    private var popupKind: PopupKind = .name
    private var errorMessage: String = ""
    private var messages: [Message] = []
    private var userName: String = "iPhone"
    private var serverURL: String = "http://192.168.80.226:5000/chat"
    private var keyboardHeight: CGFloat = 0
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendStackView: UIStackView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        self.buttonTapped()
    }
    
    private var alertController: UIAlertController?
    private var saveAction: UIAlertAction?
    
    private var chatHubConnection: HubConnection?
    private var streamHandle: StreamHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userName = UserDefaults.standard.string(forKey: "UserName") {
            self.userName = userName
        }
        
        self.messageTextView.delegate = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.separatorStyle = .none
        
        self.connectSocket()
        self.registerXib()
        self.setKeyboardDown()

        self.sendButton.setTitle("Send", for: .normal) // 버튼에 표시할 텍스트 설정
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    
    private func connectSocket() {
        self.chatHubConnection = HubConnectionBuilder(url: URL(string: self.serverURL)!)
            .withAutoReconnect()
            .build()

        self.chatHubConnection?.delegate = self
        
        self.chatHubConnection?.on(method: "NewMessage", callback: { (message: Message) in
            self.addMessage(message: message)
        })
        
        self.chatHubConnection?.start()
    }
    
    private func registerXib() {
        // let nibName = UINib(nibName: MessageTableViewCell.identifier, bundle: nil)
        tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: MessageTableViewCell.identifier)
    }
    
    private func setKeyboardDown() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    private func showPopup() {
        
        switch popupKind {
        case .error, .errorRestart:
            alertController = UIAlertController(title: "에러", message: self.errorMessage, preferredStyle: .alert)
            saveAction = UIAlertAction(title: "OK", style: .default)

        case .reconnect:
            alertController = UIAlertController(title: "Connection Lost", message: "Reconnecting...", preferredStyle: .alert)
            
            guard let alertController else { return }
            present(alertController, animated: true, completion: nil)
            
            return
            
        default:
            return
        }
        
        guard let alertController else { return }
        guard let saveAction else { return }
        
        alertController.addAction(saveAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func addMessage(message: Message) {
        
        self.messages.append(message)
        
        self.tableView.reloadData()
        
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        
        self.messageTextView.text = nil
    }
    
    @objc func handleTap() {
        messageTextView.resignFirstResponder()
    }

    @objc func buttonTapped() {
        
        // self.handleTap()
        
        if self.messageTextView.text == "/dadjoke" {
            chatHubConnection?.invoke(method: "DadJoke", resultType: String.self, invocationDidComplete: { result, error in
                if let e = error {
                    self.errorMessage = "\(e.localizedDescription)"
                    self.popupKind = .error
                    self.showPopup()
                } else {
                    self.addMessage(message: Message(name: "Dad", text: "Dad is tired today"))
                }
            })
            return
        }
        
        if self.messageTextView.text == "/count" {
            guard streamHandle == nil else {
                return
            }
            
            streamHandle = chatHubConnection?.stream(method: "CountDown", 5, streamItemReceived: { (n: Int) in
                self.addMessage(message: Message(name: "Counter", text: "\(n)"))
            }, invocationDidComplete: { error in
                self.addMessage(message: Message(name: "Counter", text: "Counting Finished!"))
            })
            
            self.messageTextView.text = nil
            return
        }
        
        if self.messageTextView.text == "/cancel" {
            guard let streamHandle else { return }
            
            chatHubConnection?.cancelStreamInvocation(streamHandle: streamHandle, cancelDidFail: {_ in })
            self.messageTextView.text = ""
            return
        }
        
        self.chatHubConnection?.send(method: "Broadcast", Message(name: self.userName, text: self.messageTextView.text)) {
            error in
            if let e = error {
                self.errorMessage = "\(e.localizedDescription)"
                self.popupKind = .error
                self.showPopup()
            } else {
                self.messageTextView.text = nil
            }
        }
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.identifier, for: indexPath) as! MessageTableViewCell
        
//        cell.nameLabel.text = messages[indexPath.row].name
//        cell.messageLabel.text = messages[indexPath.row].text
        cell.config(name: messages[indexPath.row].name, message: messages[indexPath.row].text)
        
        return cell
    }

}

extension ViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.setKeyboardDown()
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    private func moveStackView(_ stackView: UIStackView, moveDistance: CGFloat) {
        let moveDuration = 0.3
        let movement: CGFloat = moveDistance

        UIView.animate(withDuration: moveDuration) {
            
            stackView.frame = stackView.frame.offsetBy(dx: 0, dy: -movement)
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRect = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRect.height
            
            self.keyboardHeight = keyboardHeight
            self.moveStackView(self.sendStackView, moveDistance: self.keyboardHeight)
        }
    }
}

extension ViewController: HubConnectionDelegate {
    // HubConnectionLifecycle 관련 Delegate 메서드들
    
    func connectionDidOpen(hubConnection: SignalRClient.HubConnection) {
        
    }
    
    func connectionDidFailToOpen(error: Error) {
        errorMessage = "\(error.localizedDescription)"
        popupKind = .errorRestart
        showPopup()
    }
    
    func connectionDidClose(error: Error?) {
        if let e = error {
            errorMessage = "\(e.localizedDescription)"
            popupKind = .errorRestart
            showPopup()

        } else {
            
        }
    }
    
    func connectionWillReconnect(error: Error) {
        popupKind = .reconnect
        showPopup()
    }
    
    func connectionDidReconnect() {
        popupKind = .none
        self.alertController?.dismiss(animated: true)
    }
}
