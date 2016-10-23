//
//  XMPPServiceManager.h
//  ChatSecure
//
//  Created by Christopher Ballinger on 11/25/14.
//  Copyright (c) 2014 Christopher Ballinger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPServiceListener.h"

@interface XMPPServiceManager : NSObject <XMPPServiceListener>

/**
 *  Creates new XMPPService and uses it to connect to XMPP server.
 *  If myJID is already connected this method does nothing.
 *
 *  @param myJID    Jabber ID e.g. user@example.com
 *  @param password plaintext password
 */
- (void)connectWithJID:(NSString*)myJID
              password:(NSString*)password;

@end
