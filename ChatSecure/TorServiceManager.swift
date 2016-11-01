//
//  TorServiceManager.swift
//  ChatSecure
//
//  Created by Chris Ballinger on 10/31/16.
//  Copyright © 2016 Christopher Ballinger. All rights reserved.
//

import Cocoa

public class TorServiceManager: NSObject {
    private let connection = NSXPCConnection(serviceName: "com.chrisballinger.TorService")
    private let torService: TorServiceProtocol
    
    private let xmppServerPort: UInt16 = 5269
    
    deinit {
        connection.invalidate()
    }
    
    public override init() {
        connection.remoteObjectInterface = NSXPCInterface(with: TorServiceProtocol.self)
        //connection.exportedObject = self
        connection.resume()
        torService = connection.remoteObjectProxyWithErrorHandler({ (error: Error) in
            NSLog("error: %@", error as NSError)
        }) as! TorServiceProtocol
    }
    
    public func setup(completion: @escaping (String?, UInt, String?, Error?) -> (Void)) {
        torService.setup(completion: completion, internalPort: xmppServerPort, externalPort: xmppServerPort, serviceDirectoryName: "prosody")
    }
}
