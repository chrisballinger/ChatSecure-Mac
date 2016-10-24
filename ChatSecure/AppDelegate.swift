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

    let serviceManager = XMPPServiceManager()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        DDLog.add(DDTTYLogger.sharedInstance())
        DDLog.add(DDASLLogger.sharedInstance())
        serviceManager.connect(withJID: kXMPPTestAccountJID, password: kXMPPTestAccountPassword)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

