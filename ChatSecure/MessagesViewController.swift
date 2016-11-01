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
        
        if let appDelegate = NSApplication.shared().delegate as? AppDelegate {
            appDelegate.torServiceManager.setup(completion: { (socksHost: String?, socksPort: UInt, onionService: String?, error: Error?) -> (Void) in
                if let error = error as? NSError {
                    NSLog("Tor setup error: %@", error)
                    return
                }
                guard let socksHost = socksHost else {
                    return
                }
                guard let onion = onionService else {
                    return
                }
                NSLog("SOCKS: %@:%d @ %@", socksHost, socksPort, onion)
                
                appDelegate.luaServiceManager.runProsody(completion: { (result: String, error: Error?) -> (Void) in
                    if error == nil {
                        //appDelegate.xmppServiceManager.connect(withJID: kXMPPTestAccountJID, password: kXMPPTestAccountPassword)
                    }
                    
                })
            })
            
            

        }
        

    }
    
}
