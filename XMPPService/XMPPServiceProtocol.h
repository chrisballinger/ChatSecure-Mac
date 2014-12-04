//
//  XMPPServiceProtocol.h
//  XMPPService
//
//  Created by Christopher Ballinger on 11/19/14.
//  Copyright (c) 2014 Christopher Ballinger. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMPPMessage;

typedef NS_ENUM(NSUInteger, XMPPConnectionStatus) {
    XMPPConnectionStatusDisconnected,
    XMPPConnectionStatusConnecting,
    XMPPConnectionStatusAuthenticating,
    XMPPConnectionStatusConnected,
};

@protocol XMPPServiceProtocol

#pragma mark Connection
/** @name Connection */

/**
 *  Connects to XMPP server.
 *
 *  @param myJID    Jabber ID e.g. user@example.com
 *  @param password plaintext password
 *  @param completionBlock does not reflect full connection state, see setConnectionStatusBlock:
 */
- (void)connectWithJID:(NSString*)myJID
              password:(NSString*)password
       completionBlock:(void (^)(BOOL success, NSError *error))completionBlock;

/**
 *  Creates and connects to a new account on XMPP server.
 *
 *  @param newJID   New Jabber ID e.g. user@example.com
 *  @param password plaintext password
 *  @param completionBlock does not reflect full connection state, see setConnectionStatusBlock:
 */
- (void)connectWithNewJID:(NSString*)newJID
                 password:(NSString*)password
          completionBlock:(void (^)(BOOL success, NSError *error))completionBlock;

/**
 *  Disconnects from XMPP server.
 */
- (void)disconnect;

/**
 *  Register a statusBlock to observe connection status updates.
 *
 *  @param statusBlock block called when XMPPServiceStatus changes
 */
- (void)setConnectionStatusBlock:(void (^)(XMPPConnectionStatus status, NSError *error))statusBlock;

#pragma mark Data
/** @name Data */

/**
 *  New message has arrived.
 *
 *  @param incomingMessageBlock called when new messages arrive from the server
 */
- (void)setIncomingMessageBlock:(void (^)(XMPPMessage *message))incomingMessageBlock;

@end

