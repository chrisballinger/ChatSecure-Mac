//
//  LuaServiceManager.swift
//  ChatSecure
//
//  Created by Chris Ballinger on 10/29/16.
//  Copyright © 2016 Christopher Ballinger. All rights reserved.
//

import Foundation

public class LuaServiceManager: NSObject {
    private let connection = NSXPCConnection(serviceName: "org.chatsecure.LuaService")
    private let luaService: LuaServiceProtocol
    
    deinit {
        luaService.terminate()
        connection.invalidate()
    }
    
    public override init() {
        connection.remoteObjectInterface = NSXPCInterface(with: LuaServiceProtocol.self)
        //connection.exportedObject = self
        connection.resume()
        luaService = connection.remoteObjectProxyWithErrorHandler({ (error: Error) in
            NSLog("luaService XPC error: %@", error as NSError)
        }) as! LuaServiceProtocol
    }
    
    public func generateConfiguration(onionAddress: String, allowRegistration: Bool, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        luaService.generateConfiguration(withOnionAddress: onionAddress, allowRegistration: allowRegistration, completion: completion)
    }
    
    public func runProsody(completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        luaService.runProsody(completion)
    }
}
