//
//  XMPPServiceListener.h
//  ChatSecure
//
//  Created by Chris Ballinger on 10/23/16.
//  Copyright © 2016 Christopher Ballinger. All rights reserved.
//

@import Foundation;
@import XMPPFramework;

typedef NS_ENUM(NSUInteger, XMPPConnectionStatus) {
    XMPPConnectionStatusDisconnected,
    XMPPConnectionStatusConnecting,
    XMPPConnectionStatusAuthenticating,
    XMPPConnectionStatusConnected,
};

NS_ASSUME_NONNULL_BEGIN
@protocol XMPPServiceListener <NSObject>
@required

- (void) handleIncomingMessage:(XMPPMessage*)message streamTag:(id<NSSecureCoding>)streamTag;

- (void) handleConnectionStatus:(XMPPConnectionStatus)status streamJID:(XMPPJID*)streamJID error:(nullable NSError *)error streamTag:(NSString*)streamTag;

@end
NS_ASSUME_NONNULL_END
