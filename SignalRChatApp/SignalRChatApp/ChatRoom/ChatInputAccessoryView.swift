//
//  ChatInputAccessoryView.swift
//  SignalRChatApp
//
//  Created by DongKyu Kim on 2023/10/30.
//

import UIKit

class ChatInputAccessoryView: UIView {
        
    
    lazy var addButton = {
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let buttonImage = UIImage(systemName: "plus", withConfiguration: symbolConfiguration)
        let button = UIButton(image: buttonImage ?? .init(), tintColor: .gray)
        
        return button
    }()
    
    let textView = UITextView()
    let sendButton = UIButton(title: "SEND", titleColor: .black, font: .boldSystemFont(ofSize: 14), target: nil, action: nil)
    
    let placeholderLabel = UILabel(text: "Enter Message", font: .systemFont(ofSize: 16), textColor: .lightGray)
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupShadow(opacity: 0.1, radius: 8, offset: .init(width: 0, height: -8), color: .lightGray)
        autoresizingMask = .flexibleHeight
        
        textView.isScrollEnabled = false
        textView.font = .systemFont(ofSize: 16)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange), name: UITextView.textDidChangeNotification, object: nil)
        
        hstack(addButton.withSize(.init(width: 60, height: 60)), textView,
                       sendButton.withSize(.init(width: 60, height: 60)),
                       alignment: .center
            ).withMargins(.init(top: 0, left: 0, bottom: 0, right: 0))
        
        addSubview(placeholderLabel)
        placeholderLabel.anchor(top: nil, leading: addButton.trailingAnchor, bottom: nil, trailing: sendButton.leadingAnchor, padding: .init(top: 0, left: 10, bottom: 0, right: 0))
        placeholderLabel.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor).isActive = true
    }
    
    @objc func handleTextChange() {
        // Placeholder Label isHidden
        
        if textView.text.count == 0 || textView.text == nil {
            placeholderLabel.isHidden = false
        }
        
        if textView.attributedText.length != 0 {
            placeholderLabel.isHidden = true
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
