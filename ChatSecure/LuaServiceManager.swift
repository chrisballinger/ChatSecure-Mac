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
        connection.invalidate()
    }
    
    public override init() {
        connection.remoteObjectInterface = NSXPCInterface(with: LuaServiceProtocol.self)
        //connection.exportedObject = self
        connection.resume()
        luaService = connection.remoteObjectProxyWithErrorHandler({ (error: Error) in
            NSLog("error: %@", error as NSError)
        }) as! LuaServiceProtocol
    }
    
    public func runProsody(completion: @escaping (String, Error?) -> (Void)) {
        luaService.runProsody(completion)
    }
}
