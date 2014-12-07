//
//  XMPPServiceProtocol.h
//  XMPPService
//
//  Created by Christopher Ballinger on 11/19/14.
//  Copyright (c) 2014 Christopher Ballinger. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMPPMessage;
@class XMPPJID;

typedef NS_ENUM(NSUInteger, XMPPConnectionStatus) {
    XMPPConnectionStatusDisconnected,
    XMPPConnectionStatusConnecting,
    XMPPConnectionStatusAuthenticating,
    XMPPConnectionStatusConnected,
};

typedef void (^XMPPIncomingMessageBlock)(XMPPJID *streamJID, XMPPMessage *message, NSUInteger remainingReplyBlocks);
typedef void (^XMPPConnectionStatusBlock)(XMPPJID *streamJID, XMPPConnectionStatus status, NSError *error, NSUInteger remainingReplyBlocks);
typedef void (^XMPPReplyQueueCountBlock)(NSUInteger remainingReplyBlocks);

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
 *  Register a statusBlock to observe connection status updates. Because you cannot reuse a block
 *  for multiple replies due to XPC limitations, we must keep an internal queue of ongoing
 *  message blocks. You should enqueue more incomingMessageBlocks when remainingReplyBlocks becomes low.
 *
 *  @param statusBlock block called when XMPPServiceStatus changes
 */
- (void)enqueueConnectionStatusBlock:(XMPPConnectionStatusBlock)connectionStatusBlock;

/**
 *  Returns the number of enqueued connection status blocks.
 */
- (void)checkConnectionStatusBlockCount:(XMPPReplyQueueCountBlock)replyQueueCountBlock;

#pragma mark Data

/** @name Data */

/**
 *  Enqueue a new incoming message block. Because you cannot reuse a block for multiple replies
 *  due to XPC limitations, we must keep an internal queue of ongoing message blocks. You should
 *  enqueue more incomingMessageBlocks when remainingReplyBlocks becomes low.
 *
 *  @param incomingMessageBlock called when new messages arrive from the server
 */
- (void)enqueueIncomingMessageBlock:(XMPPIncomingMessageBlock)incomingMessageBlock;

/**
 *  Returns the number of enqueued incoming message blocks.
 */
- (void)checkIncomingMessageBlockCount:(XMPPReplyQueueCountBlock)replyQueueCountBlock;


@end

