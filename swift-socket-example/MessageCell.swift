//
//  MessageCell.swift
//  swift-socket-example
//
//  Created by Yuta Akizuki on 2014/12/22.
//  Copyright (c) 2014年 ytakzk.me. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    private var message: MessageModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setContent(message:MessageModel) {
        self.message = message
        self.nameLabel.text = message.name
        self.messageLabel.text = message.message
    }

}
