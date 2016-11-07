//
//  ProsodyServerViewController.swift
//  ChatSecure
//
//  Created by Chris Ballinger on 11/6/16.
//  Copyright © 2016 Christopher Ballinger. All rights reserved.
//

import Cocoa

public class ProsodyServerViewController: NSViewController {
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var addressLabel: NSTextField!
    @IBOutlet weak var certLabel: NSTextField!
    
    public var luaService: LuaServiceManager?
    public var torService: TorServiceManager?

    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        luaService = LuaServiceManager()
        torService = TorServiceManager()
        startEverything()
    }
    
    public override func viewDidAppear() {
        super.viewDidAppear()
        
    }
    
    private func startEverything() {
        guard let tor = torService else {
            statusLabel.stringValue = "Error: TorService is nil."
            return
        }
        guard let lua = luaService else {
            statusLabel.stringValue = "Error: LuaService (Prosody) is nil."
            return
        }
        statusLabel.stringValue = "Starting Tor..."
        tor.setup(completion: { (socksHost: String?, socksPort: UInt, onionService: String?, error: Error?) -> (Void) in
            if let error = error as? NSError {
                self.statusLabel.stringValue = "Tor setup error: \(error)"
                NSLog("Tor setup error: %@", error)
                return
            }
            guard let socksHost = socksHost else {
                self.statusLabel.stringValue = "Tor setup error: No SOCKS host!"
                return
            }
            guard let onion = onionService else {
                self.statusLabel.stringValue = "Tor setup error: No onion address!"
                return
            }
            self.addressLabel.stringValue = onion
            NSLog("SOCKS: %@:%d @ %@", socksHost, socksPort, onion)
            
            self.statusLabel.stringValue = "Starting Prosody..."
            lua.generateConfiguration(onionAddress: onion, allowRegistration: true, completion: { (success: Bool, error: Error?) -> (Void) in
                if let error = error as? NSError {
                    self.statusLabel.stringValue = "generateConfiguration error: \(error)"
                    NSLog("generateConfiguration error: %@", error)
                    return
                }
                lua.runProsody(completion: { (result: Bool, error: Error?) -> (Void) in
                    if let error = error as? NSError {
                        self.statusLabel.stringValue = "runProsody error: \(error)"
                        NSLog("runProsody error: %@", error)
                        return
                    }
                })
                self.statusLabel.stringValue = "Running"
            })
        })
    }
    
}
