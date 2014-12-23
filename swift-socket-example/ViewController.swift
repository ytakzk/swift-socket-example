//
//  ViewController.swift
//  swift-socket-example
//
//  Created by Yuta Akizuki on 2014/12/22.
//  Copyright (c) 2014年 ytakzk.me. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputAreaView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var settingsViewConstraintMarginTop: NSLayoutConstraint!
    var settingsViewController:SettingsViewController! = nil
    var settingsViewIsDisplayed = false
    
    var messages: Array<MessageModel>?
    var socket:SIOSocket! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        messages = []
        
        SIOSocket.socketWithHost("ws://localhost:3000", response:  { (_socket: SIOSocket!) in
            self.socket = _socket
            
            self.socket.onConnect = {() in
                println("connected")
                self.socket.emit("message init", args: [])
            }
            
            self.socket.onReconnect = { (attempts: Int) in
                
            }
            
            self.socket.onDisconnect = {() in
                println("disconnected")
            }
            
            // メッセージを受信
            self.socket.on("message send", callback:{(data:[AnyObject]!)  in
                let dic = data[0] as NSDictionary
                let model = MessageModel(_name: dic["name"] as String, _message: dic["message"] as String)
                self.messages?.append(model)
                self.tableView.reloadData()
            })
            
            // メッセージの初期化
            self.socket.on("message init", callback:{(data:[AnyObject]!)  in
                let arr = data[0] as NSArray
                for var i = 0; i < arr.count; i++ {
                    let dic = arr[i] as NSDictionary
                    let model = MessageModel(_name: dic["name"] as String, _message: dic["message"] as String)
                    self.messages?.append(model)
                }
                self.tableView.reloadData()
                // tableviewのスクロールを一番下まで動かす
                UIView.animateWithDuration(0.2, delay: 3.0, options: nil, animations: {}, completion: {(finished) -> Void in
                    let indexPath = NSIndexPath(forRow:(self.tableView.numberOfRowsInSection(0) as Int - 1), inSection: self.tableView.numberOfSections()-1 as Int)
                    self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
                    
                })
            })
        })
        
        // SettingsViewControllerを取得
        self.settingsViewController = self.childViewControllers[0] as SettingsViewController
        //SettingsViewControllerを閉じた時
        self.settingsViewController.closeMe = {
            self.moveSettingsView()
            self.settingsViewIsDisplayed = false
        }
        
        // tableViewの高さを可変にする
        self.tableView.estimatedRowHeight = 49
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // textviewのスクロールのバグ修正
        textView.scrollEnabled = false;
        textView.scrollEnabled = true;
        
        // 装飾周り
        textView.layer.borderColor = UIColor(white: 0.5, alpha: 0.2).CGColor
        textView.layer.borderWidth = 0.5
        var inputViewLayer = CALayer()
        inputViewLayer.frame = CGRect(x: 0, y: 0, width: inputAreaView.frame.width, height: 1)
        inputViewLayer.backgroundColor = UIColor(white: 0.5, alpha: 0.3).CGColor
        inputAreaView.layer.addSublayer(inputViewLayer)
        sendButton.layer.cornerRadius = 2.0
        
        // イベント系
        sendButton.addTarget(self, action: "sended:", forControlEvents: UIControlEvents.TouchUpInside)
        settingsButton.addTarget(self, action: "settingsPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillAppear:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TableViewDelegate
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int  {
        return messages!.count
    }
    
    func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath:NSIndexPath!) -> UITableViewCell! {
        var cell: MessageCell = self.tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as MessageCell
        let message = messages![indexPath.row]
        cell.setContent(message)
        return cell
    }
    
    func tableView(tableView: UITableView?, didSelectRowAtIndexPath indexPath:NSIndexPath!) {
        
    }
    
    // MARK: - textFieldDelegate
    func textViewDidBeginEditing(textView: UITextView) {
    }

    func textViewDidEndEditing(textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        // autolayoutのconstraintを変更してtextviewの高さを可変にする
        let maxHeight:CGFloat = 60.0
        let size = textView.sizeThatFits(textView.frame.size)
        if (textView.frame.height < maxHeight) {
            self.textViewConstraintHeight.constant = size.height
        }
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    // MARK: - keyboardNotification
    func keyboardWillAppear(notification: NSNotification) {
        // settingsViewが表示されている時(TexiField)
        if (settingsViewIsDisplayed) {
            return
        }

        // キーボードの高さだけ全体にオフセットを与える
        var rect:NSValue
        var duration: NSTimeInterval
        if let userInfo = notification.userInfo as? Dictionary<String,AnyObject> {
            rect = userInfo["UIKeyboardFrameEndUserInfoKey"] as NSValue
            duration = userInfo["UIKeyboardAnimationDurationUserInfoKey"] as NSTimeInterval
            
            let transform = CGAffineTransformMakeTranslation(0, -rect.CGRectValue().size.height)
            
            UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut,
                animations: {() -> Void in
                    self.view.transform = transform
                }, completion: {(finished) in
            })
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        // settingsViewが表示されている時(TexiField)
        if (settingsViewIsDisplayed) {
            return
        }

        // 与えたオフセットを取り除く
        var duration: NSTimeInterval
        if let userInfo = notification.userInfo as? Dictionary<String,AnyObject> {
            duration = userInfo["UIKeyboardAnimationDurationUserInfoKey"] as NSTimeInterval
            
            UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut,
                animations: {() -> Void in
                    self.view.transform = CGAffineTransformIdentity
                }, completion: {(finished) in
            })
        }
    }
    
    // MARK: - Button Event
    func sended(sender: UIButton!) {
        if !MyUtils().stringHasContent(textView.text) {
            return
        }
        let username = (MyUtils().stringHasContent(MyUtils().username)) ? MyUtils().username! : "Mr. Unknown"
        
        // ソケットにemitする
        let model = NSDictionary(dictionary: ["name": username, "message": textView.text, "date": convertDateToStr(NSDate())]);
        socket.emit("message send", args:[model] as SIOParameterArray)
        
        // texiviewの高さを元に戻す
        textView.text = nil
        let size = textView.sizeThatFits(textView.frame.size)
        self.textViewConstraintHeight.constant = size.height
        
        textView.resignFirstResponder()
    }
    
    private func convertDateToStr(date:NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return dateFormatter.stringFromDate(date)
    }
    
    func settingsPressed(sender: UIButton!) {
        settingsViewIsDisplayed = true
        moveSettingsView()
        self.settingsViewController.textField.becomeFirstResponder()
    }
    
    func moveSettingsView() {
        var offset:CGFloat = 0.0

        if (self.settingsViewConstraintMarginTop.constant == 0) {
            offset = self.settingsView.frame.height
        } else {
            offset = 0.0
        }
        
        self.view.removeConstraint(self.settingsViewConstraintMarginTop)
        
        self.settingsViewConstraintMarginTop = NSLayoutConstraint(
            item: self.view!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal,
            toItem: self.settingsView, attribute: NSLayoutAttribute.Top,
            multiplier: 1, constant: offset)
        
        self.view.addConstraint(self.settingsViewConstraintMarginTop)
        
        UIView.animateWithDuration(0.24,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseIn,
            animations: {() -> Void in
                self.view.layoutIfNeeded()
            },
            completion: nil)
    }
    

}

