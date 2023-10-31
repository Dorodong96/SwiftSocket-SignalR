//
//  MessageLabel.swift
//  SignalRChatApp
//
//  Created by DongKyu Kim on 2023/10/31.
//

import UIKit

class MessageLabel: UILabel {

    private var padding = UIEdgeInsets(top: 2.0, left: 4.0, bottom: 2.0, right: 4.0)

    convenience init(padding: UIEdgeInsets = UIEdgeInsets(top: 2.0, left: 4.0, bottom: 2.0, right: 4.0)) {
        self.init()
        self.padding = padding
    }
    
    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += padding.top + padding.bottom
        contentSize.width += padding.left + padding.right

        return contentSize
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
}
