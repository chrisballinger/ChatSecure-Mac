//
//  XMPPServiceManager.m
//  ChatSecure
//
//  Created by Christopher Ballinger on 11/25/14.
//  Copyright (c) 2014 Christopher Ballinger. All rights reserved.
//

#import "XMPPServiceManager.h"
#import "XMPPServiceProtocol.h"
@import XMPPFramework;

@interface XMPPServiceManager()
@property (nonatomic, strong, readonly) NSXPCConnection *xmppServiceConnection;
@property (nonatomic, readonly) dispatch_queue_t connectionQueue;
@property (nonatomic, strong, readonly) id<XMPPServiceProtocol> xmppService;
@end

@implementation XMPPServiceManager

- (instancetype) init {
    if (self = [super init]) {
    }
    return self;
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
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _xmppServiceConnection = [[NSXPCConnection alloc] initWithServiceName:@"com.chrisballinger.XMPPService"];
        self.xmppServiceConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(XMPPServiceProtocol)];
        self.xmppServiceConnection.exportedObject = self;
        self.xmppServiceConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(XMPPServiceListener)];
        [self.xmppServiceConnection resume];
        _xmppService = [self.xmppServiceConnection remoteObjectProxyWithErrorHandler:^(NSError *error) {
            NSLog(@"Error with XPC for %@: %@", myJID, error);
        }];
    });
    
    [self.xmppService connectWithJID:myJID password:password completionBlock:^(BOOL success, NSError *error) {
        if (error) {
            NSLog(@"Error connecting to %@: %@", myJID, error);
        } else {
            NSLog(@"Starting connection to %@...", myJID);
        }
    }];
}

#pragma mark XMPPServiceListener

- (void) handleIncomingMessage:(XMPPMessage*)message streamTag:(id<NSSecureCoding>)streamTag {
    NSLog(@"handleIncomingMessage: %@ %@ %@", message, [message from], streamTag);
    
    if ([message isMessageWithBody]) {
        NSLog(@"Incoming message with body: %@", [message body]);
    }
    if ([message isErrorMessage]) {
        NSError *error = [message errorMessage];
        NSLog(@"Incoming message error: %@", error);
    }
}

- (void) handleConnectionStatus:(XMPPConnectionStatus)status streamJID:(XMPPJID*)streamJID error:(nullable NSError *)error streamTag:(NSString*)streamTag {
    switch (status) {
        case XMPPConnectionStatusConnected:
            NSLog(@"Connected to %@!", streamJID);
            break;
        case XMPPConnectionStatusConnecting:
            NSLog(@"Connecting to %@...", streamJID);
            break;
        case XMPPConnectionStatusDisconnected:
            NSLog(@"Disconnected from %@ %@", streamJID, error);
            break;
        case XMPPConnectionStatusAuthenticating:
            NSLog(@"Authenticating %@...", streamJID);
            break;
    }
}

@end
