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
    
    lazy var accessoryView: ChatInputAccessoryView = {
        let accessoryView = ChatInputAccessoryView(frame: .init(x: 0, y: 0, width: view.frame.width, height: 60))
        accessoryView.translatesAutoresizingMaskIntoConstraints = false
        accessoryView.addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        accessoryView.sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        return accessoryView
    }()
    
    lazy var messageTextView: UITextView = {
        let textView = self.accessoryView.textView
        return textView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return accessoryView
        }
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
        self.setChatInputAccesoryViewLayout()
        
        self.messageTextView.inputAccessoryView = self.accessoryView
        self.addTapGesture()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.separatorStyle = .none
        self.tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: MessageTableViewCell.reuseIdentifier)
        
        self.connectSocket()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        // 알림 구독 해제
        NotificationCenter.default.removeObserver(self)
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
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardDown))
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
        
        let indexPath = IndexPath(row: messages.count-1, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .bottom)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        
        self.messageTextView.text = ""
    }

    @objc func hideKeyboardDown(_ sender: Any) {
        self.setChatInputAccesoryViewLayout()
        self.accessoryView.endEditing(true)
    }
    
    @objc func sendButtonTapped() {
        
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
    
    private func setChatInputAccesoryViewLayout() {
        self.view.addSubview(accessoryView)
        
        self.accessoryView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 12).isActive = true
        self.accessoryView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12).isActive = true
        self.accessoryView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -12).isActive = true
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.reuseIdentifier, for: indexPath) as! MessageTableViewCell

        cell.config(name: messages[indexPath.row].name, message: messages[indexPath.row].text)
        
        return cell
    }

}

extension ViewController {
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRect = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRect.height
            
            self.keyboardHeight = keyboardHeight
            
            if keyboardHeight > 0 {
                self.tableView.setContentOffset(CGPoint(x: self.tableView.bounds.minX, y: self.tableView.bounds.minY), animated: false)
            }
            
            self.tableView.contentInset.bottom = keyboardHeight - 60
            self.tableView.verticalScrollIndicatorInsets.bottom = .zero
            
            
            if !self.messages.isEmpty {
                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        // 키보드 사라질 때 contentInset 및 scrollIndicatorInsets 초기화
        tableView.contentInset = .zero
        tableView.scrollIndicatorInsets = .zero
    }
}

extension ViewController: HubConnectionDelegate {
    // HubConnectionLifecycle 관련 Delegate 메서드들
    
    func connectionDidOpen(hubConnection: SignalRClient.HubConnection) {
        
    }
    
    func connectionDidFailToOpen(error: Error) {
        errorMessage = "\(error.localizedDescription)" + "에러타입 1"
        popupKind = .errorRestart
        showPopup()
    }
    
    func connectionDidClose(error: Error?) {
        if let e = error {
            errorMessage = "\(e.localizedDescription)" + "에러타입 2"
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

extension ViewController {
    @objc
    private func addButtonTapped() {
        self.accessoryView.endEditing(true)
        
        let alertController = UIAlertController(title: "이미지 선택", message: "이미지를 어디서 가져올까요?", preferredStyle: .actionSheet)

            // 카메라로 가져오기
            let takePhotoAction = UIAlertAction(title: "카메라로 사진 찍기", style: .default) { (action) in
                self.presentImagePicker(sourceType: .camera)
            }
                
            // 앨범에서 가져오기
            let choosePhotoAction = UIAlertAction(title: "앨범에서 사진 선택", style: .default) { (action) in
                self.presentImagePicker(sourceType: .photoLibrary)
            }

            // 취소
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)

            alertController.addAction(takePhotoAction)
            alertController.addAction(choosePhotoAction)
            alertController.addAction(cancelAction)

            self.present(alertController, animated: true, completion: nil)
    }
    
    func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = sourceType
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            // 선택한 소스 타입이 사용 불가능한 경우에 대한 처리
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    // UIImagePickerControllerDelegate 메서드 구현
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            
            let text = NSMutableAttributedString(string: self.messageTextView.text, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0)])
            
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = selectedImage.resizeImage(width: 100, height: 100)
            let imageString = NSAttributedString(attachment: imageAttachment)
            
            text.append(imageString)
            text.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16.0), range: NSRange(location: 0, length: text.length))
            
            self.accessoryView.placeholderLabel.isHidden = true
            self.messageTextView.attributedText = text
        }
        picker.dismiss(animated: true, completion: nil) 
        self.setChatInputAccesoryViewLayout()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

/**
 RxKeyboard.instance.visibleHeight
   .distinctUntilChanged()
   .asDriver(onErrorDriveWith: .empty())
   .drive(onNext: { [weak self] height in
     guard let self = self else { return }
     var keyboardHeight:CGFloat = 0
     if height > 0 {
       keyboardHeight = height - UIApplication.shared.windows.first!.safeAreaInsets.bottom
       self.tableView.setContentOffset(CGPoint(x: self.tableView.bounds.minX, y: self.tableView.bounds.minY + keyboardHeight), animated: false)
     } else {
       keyboardHeight = height
       self.tableView.setContentOffset(CGPoint(x: self.tableView.bounds.minX, y: self.tableView.bounds.minY - self.tableView.contentInset.bottom), animated: false)
     }
     self.tableView.contentInset.bottom = keyboardHeight
     self.tableView.verticalScrollIndicatorInsets.bottom = keyboardHeight
   })
   .disposed(by: disposeBag)
**/
