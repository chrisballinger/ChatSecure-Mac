//
//  MessagesViewController.swift
//  ChatSecure
//
//  Created by Chris Ballinger on 10/23/16.
//  Copyright © 2016 Christopher Ballinger. All rights reserved.
//

import Cocoa

class MessagesViewController: NSViewController {

    @IBOutlet weak var chatHistoryTableView: NSTableView!
    @IBOutlet weak var messageTextField: NSTextField!
    @IBOutlet weak var sendButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func sendButtonPressed(_ sender: AnyObject) {
        let messageText = messageTextField.stringValue
        NSLog("Send: %@", messageText)
        messageTextField.stringValue = ""
        

        

    }
    
}
