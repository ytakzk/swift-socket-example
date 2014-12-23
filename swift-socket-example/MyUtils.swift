//
//  MyUtils.swift
//  swift-socket-example
//
//  Created by Yuta Akizuki on 2014/12/23.
//  Copyright (c) 2014年 ytakzk.me. All rights reserved.
//

import UIKit

class MyUtils: NSObject {
    var username: String? {
        set(value) {
            NSUserDefaults.standardUserDefaults().setObject(value, forKey: "NAME")
        }
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("NAME")
        }
    }
    
    // stringが改行とかスペースだけかを判断
    func stringHasContent(str:String?) -> Bool {
        if let trimmedStr = str?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
            if (trimmedStr.utf16Count > 0) {
                return true
            }
        }
        return false
    }
    
}
