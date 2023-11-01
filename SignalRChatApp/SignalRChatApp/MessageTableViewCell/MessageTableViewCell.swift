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
    
    static let reuseIdentifier: String = "MessageTableViewCell"
    private var cellType: MessageType = .receiveText
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 21)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var messageLabel: MessageLabel = {
        let label = MessageLabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.numberOfLines = 0
        label.layer.cornerRadius = 5.0
        label.layer.masksToBounds = true
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
            self.cellType = .sendText
        } else {
            self.cellType = .receiveText
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutIfNeeded() {
        self.addSubview(nameLabel)
        self.addSubview(messageLabel)
        
        nameLabel.textAlignment = (self.cellType == .receiveText || self.cellType == .receiveImage) ? .left : .right
        nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        let ratioInset = UIScreen.main.bounds.size.width / 3
        
        switch self.cellType {
            
        case .receiveText, .receiveImage:
            messageLabel.textAlignment = .left
            messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 12).isActive = true
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
            messageLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: ratioInset * 2).isActive = true
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -ratioInset).isActive = true
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
            
            messageLabel.backgroundColor = .cyan
            
        case .sendText, .sendImage:
            messageLabel.textAlignment = .right
            messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 12).isActive = true
            messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: ratioInset).isActive = true
            messageLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: ratioInset * 2).isActive = true
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
            
            messageLabel.backgroundColor = .orange
            
        }
    }
    
}
