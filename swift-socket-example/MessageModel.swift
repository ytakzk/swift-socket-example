//
//  MessageModel.swift
//  swift-socket-example
//
//  Created by Yuta Akizuki on 2014/12/22.
//  Copyright (c) 2014年 ytakzk.me. All rights reserved.
//

import UIKit

class MessageModel: NSObject {
    let name:String
    let message:String
    
    init(_name:String, _message:String) {
        name = _name
        message = _message
    }
}
