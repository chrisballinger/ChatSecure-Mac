//
//  XMPPServiceManager.m
//  ChatSecure
//
//  Created by Christopher Ballinger on 11/25/14.
//  Copyright (c) 2014 Christopher Ballinger. All rights reserved.
//

#import "XMPPServiceManager.h"
#import "XMPPServiceProtocol.h"
#import "XMPPMessage.h"

@interface XMPPServiceManager()
@property (nonatomic, strong, readonly) NSXPCConnection *xmppServiceConnection;
@property (nonatomic, readonly) dispatch_queue_t connectionQueue;
@property (nonatomic, strong, readonly) XMPPIncomingMessageBlock incomingMessageBlock;
@property (nonatomic, strong, readonly) XMPPConnectionStatusBlock connectionStatusBlock;

@property (nonatomic, strong, readonly) id<XMPPServiceProtocol> xmppService;
@end

@implementation XMPPServiceManager

- (instancetype) init {
    if (self = [super init]) {
        [self setupReplyBlocks];
    }
    return self;
}

- (void) setupReplyBlocks {
    __weak __typeof__(self) weakSelf = self;
    _incomingMessageBlock = ^void(XMPPJID *streamJID, XMPPMessage *message, NSUInteger remainingReplyBlocks) {
        __typeof__(self) strongSelf = weakSelf;
        NSLog(@"Incoming message: %@", message.XMLString);
        NSLog(@"remainingReplyBlocks for incoming message: %lu", (unsigned long)remainingReplyBlocks);
        if ([message isMessageWithBody]) {
            NSLog(@"Incoming message with body: %@", [message body]);
        }
        if ([message isErrorMessage]) {
            NSError *error = [message errorMessage];
            NSLog(@"Incoming message error: %@", error);
        }
        if (remainingReplyBlocks < 50) {
            [strongSelf enqueueMessageBlocksWithCount:100];
        }
    };
    _connectionStatusBlock = ^(XMPPJID *streamJID, XMPPConnectionStatus status, NSError *error, NSUInteger remainingReplyBlocks) {
        __typeof__(self) strongSelf = weakSelf;
        NSLog(@"remainingReplyBlocks for connection status: %lu", (unsigned long)remainingReplyBlocks);
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
        if (remainingReplyBlocks < 50) {
            [strongSelf enqueueConnectionStatusBlocksWithCount:100];
        }
    };
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
        [self.xmppServiceConnection resume];
        _xmppService = [self.xmppServiceConnection remoteObjectProxyWithErrorHandler:^(NSError *error) {
            NSLog(@"Error with XPC for %@: %@", myJID, error);
        }];
    });
    
    [self enqueueMessageBlocksWithCount:100];
    [self enqueueConnectionStatusBlocksWithCount:100];
    
    [self.xmppService connectWithJID:myJID password:password completionBlock:^(BOOL success, NSError *error) {
        if (error) {
            NSLog(@"Error connecting to %@: %@", myJID, error);
        } else {
            NSLog(@"Starting connection to %@...", myJID);
        }
    }];
}

- (void) enqueueMessageBlocksWithCount:(NSUInteger)count {
    for (NSUInteger i = 0; i < count; i++) {
        [self.xmppService enqueueIncomingMessageBlock:self.incomingMessageBlock];
    }
}

- (void) enqueueConnectionStatusBlocksWithCount:(NSUInteger)count {
    for (NSUInteger i = 0; i < count; i++) {
        [self.xmppService enqueueConnectionStatusBlock:self.connectionStatusBlock];
    }
}

@end
