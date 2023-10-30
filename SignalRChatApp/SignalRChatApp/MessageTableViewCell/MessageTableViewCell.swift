//
//  MessageTableViewCell.swift
//  SignalRChatApp
//
//  Created by DongKyu Kim on 2023/10/26.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    static let identifier: String = "MessageTableViewCell"
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
