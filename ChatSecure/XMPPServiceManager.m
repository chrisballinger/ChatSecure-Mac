//
//  XMPPServiceManager.m
//  ChatSecure
//
//  Created by Christopher Ballinger on 11/25/14.
//  Copyright (c) 2014 Christopher Ballinger. All rights reserved.
//

#import "XMPPServiceManager.h"
#import "XMPPServiceProtocol.h"

@interface XMPPServiceManager()
@property (nonatomic, strong, readonly) NSMutableDictionary *serviceConnections;
@property (nonatomic, readonly) dispatch_queue_t connectionQueue;
@end

@implementation XMPPServiceManager

- (instancetype) init {
    if (self = [super init]) {
        _connectionQueue = dispatch_queue_create("XMPPServiceManager connection queue", 0);
        _serviceConnections = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSXPCConnection*) newXMPPServiceConnection {
    NSXPCConnection *xmppServiceConnection = [[NSXPCConnection alloc] initWithServiceName:@"com.chrisballinger.XMPPService"];
    xmppServiceConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(XMPPServiceProtocol)];
    return xmppServiceConnection;
}


- (NSXPCConnection*)connectionForJID:(NSString*)jid {
    return [self.serviceConnections objectForKey:jid];
}

- (void) setConnection:(NSXPCConnection*)connection forJID:(NSString*)jid {
    NSParameterAssert(connection);
    NSParameterAssert(jid);
    if (!connection || !jid) {
        return;
    }
    [self.serviceConnections setObject:connection forKey:jid];
}

/**
 *  Creates new XMPPService and uses it to connect to XMPP server.
 *  If myJID is already connected this method does nothing.
 *
 *  @param myJID    Jabber ID e.g. user@example.com
 *  @param password plaintext password
 */
- (void)connectWithJID:(NSString*)myJID
              password:(NSString*)password {
    dispatch_async(_connectionQueue, ^{
        NSXPCConnection *connection = [self connectionForJID:myJID];
        if (!connection) {
            connection = [self newXMPPServiceConnection];
            [self setConnection:connection forJID:myJID];
            [connection resume];
        }
        id<XMPPServiceProtocol> xmppService = [connection remoteObjectProxyWithErrorHandler:^(NSError *error) {
            NSLog(@"Error with XPC for %@: %@", myJID, error);
        }];
        [xmppService setConnectionStatusBlock:^(XMPPConnectionStatus status, NSError *error) {
            switch (status) {
                case XMPPConnectionStatusConnected:
                    NSLog(@"Connected to %@!", myJID);
                    break;
                case XMPPConnectionStatusConnecting:
                    NSLog(@"Connecting to %@...", myJID);
                    break;
                case XMPPConnectionStatusDisconnected:
                    NSLog(@"Disconnected from %@ %@", myJID, error);
                    break;
                case XMPPConnectionStatusAuthenticating:
                    NSLog(@"Authenticating %@...", myJID);
                    break;
            }
        }];
        [xmppService connectWithJID:myJID password:password completionBlock:^(BOOL success, NSError *error) {
            if (error) {
                NSLog(@"Error connecting to %@: %@", myJID, error);
            } else {
                NSLog(@"Starting connection to %@...", myJID);
            }
        }];
        
    });
}


@end
