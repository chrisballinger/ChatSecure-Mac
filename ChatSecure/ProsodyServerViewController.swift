//
//  ProsodyServerViewController.swift
//  ChatSecure
//
//  Created by Chris Ballinger on 11/6/16.
//  Copyright © 2016 Christopher Ballinger. All rights reserved.
//

import Cocoa

public class ProsodyServerViewController: NSViewController {
    @IBOutlet weak var torStatusLabel: NSTextField!
    @IBOutlet weak var prosodyStatusLabel: NSTextField!
    @IBOutlet weak var addressLabel: NSTextField!
    @IBOutlet weak var certLabel: NSTextField!
    @IBOutlet weak var startStopButton: NSButton!
    
    public var luaService: LuaServiceManager?
    public var torService: TorServiceManager?
    
    var isRunning: Bool = false {
        didSet {
            if isRunning {
                startStopButton.title = "Stop"
            } else {
                startStopButton.title = "Start"
            }
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        resetLabels()
    }
    
    func resetLabels() {
        addressLabel.stringValue = ""
        certLabel.stringValue = ""
        torStatusLabel.stringValue = "Stopped"
        prosodyStatusLabel.stringValue = "Stopped"
    }

    @IBAction func startStopButtonPressed(_ sender: NSButton) {
        if isRunning {
            stopServices()
        } else {
            startServices()
        }
    }
    
    func startServices() {
        luaService = LuaServiceManager()
        torService = TorServiceManager()
        isRunning = true
        startEverything()
    }
    
    func stopServices() {
        luaService = nil
        torService = nil
        isRunning = false
        resetLabels()
    }
    
    private func startEverything() {
        guard let tor = torService else {
            torStatusLabel.stringValue = "Error: TorService is nil."
            return
        }
        guard let lua = luaService else {
            prosodyStatusLabel.stringValue = "Error: LuaService (Prosody) is nil."
            return
        }
        torStatusLabel.stringValue = "Starting Tor..."
        tor.setup(completion: { (socksHost: String?, socksPort: UInt, onionService: String?, error: Error?) -> (Void) in
            if let error = error as? NSError {
                self.torStatusLabel.stringValue = "Tor setup error: \(error)"
                NSLog("Tor setup error: %@", error)
                return
            }
            guard let socksHost = socksHost else {
                self.torStatusLabel.stringValue = "Tor setup error: No SOCKS host!"
                return
            }
            guard var onion = onionService else {
                self.torStatusLabel.stringValue = "Tor setup error: No onion address!"
                return
            }
            self.torStatusLabel.stringValue = "Running"
            onion = onion.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            self.addressLabel.stringValue = onion
            NSLog("SOCKS: %@:%d @ %@", socksHost, socksPort, onion)
            
            self.prosodyStatusLabel.stringValue = "Starting Prosody..."
            lua.generateConfiguration(onionAddress: onion, allowRegistration: true, completion: { (success: Bool, error: Error?) -> (Void) in
                if let error = error as? NSError {
                    self.prosodyStatusLabel.stringValue = "generateConfiguration error: \(error)"
                    NSLog("generateConfiguration error: %@", error)
                    return
                }
                lua.runProsody(completion: { (result: Bool, error: Error?) -> (Void) in
                    if let error = error as? NSError {
                        self.prosodyStatusLabel.stringValue = "runProsody error: \(error)"
                        NSLog("runProsody error: %@", error)
                        return
                    }
                })
                self.prosodyStatusLabel.stringValue = "Running"
            })
        })
    }
    
}
