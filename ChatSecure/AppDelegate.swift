//
//  AppDelegate.swift
//  ChatSecure
//
//  Created by Chris Ballinger on 10/23/16.
//  Copyright © 2016 Christopher Ballinger. All rights reserved.
//

import Cocoa
import CocoaLumberjack

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let xmppServiceManager = XMPPServiceManager()
    let luaServiceManager = LuaServiceManager()
    let torServiceManager = TorServiceManager()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        DDLog.add(DDTTYLogger.sharedInstance())
        DDLog.add(DDASLLogger.sharedInstance())
        //type(of: self).startItAll()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    static public func startItAll() {
        guard let appDelegate = NSApplication.shared().delegate as? AppDelegate else {
            return
        }
        let tor = appDelegate.torServiceManager
        let lua = appDelegate.luaServiceManager
        tor.setup(completion: { (socksHost: String?, socksPort: UInt, onionService: String?, error: Error?) -> (Void) in
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
            
            lua.generateConfiguration(onionAddress: onion, allowRegistration: true, completion: { (success: Bool, error: Error?) -> (Void) in
                if let error = error as? NSError {
                    NSLog("generateConfiguration error: %@", error)
                    return
                }
                lua.runProsody(completion: { (result: Bool, error: Error?) -> (Void) in
                    if let error = error as? NSError {
                        NSLog("runProsody error: %@", error)
                        return
                    }
                    //appDelegate.xmppServiceManager.connect(withJID: kXMPPTestAccountJID, password: kXMPPTestAccountPassword)
                    
                })
            })
            
            
        })
    }


}

