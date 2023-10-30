//
//  MessageTableViewCell.swift
//  SignalRChatApp
//
//  Created by DongKyu Kim on 2023/10/26.
//

import UIKit

private enum MessageType {
    case receiveText
    case sendText
    case receiveImage
    case sendImage
}

class MessageTableViewCell: UITableViewCell {
    
    static let identifier: String = "MessageTableViewCell"
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func config(name: String, message: String) {
        self.nameLabel.text = name
        self.messageLabel.text = message
        
        guard let userName = UserDefaults.standard.string(forKey: "UserName") else { return }
        if userName == name {
            self.setLayout(type: .sendText)
        } else {
            self.setLayout(type: .receiveText)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func setLayout(type: MessageType) {
        self.addSubview(nameLabel)
        self.addSubview(messageLabel)
        
        nameLabel.textAlignment = (type == .receiveText || type == .receiveImage) ? .left : .right
        nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        messageLabel.textAlignment = (type == .receiveText || type == .receiveImage) ? .left : .right
        messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 12).isActive = true
        messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
        messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
    }
    
}
