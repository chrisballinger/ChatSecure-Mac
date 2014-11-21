//
//  XMPPService.m
//  XMPPService
//
//  Created by Christopher Ballinger on 11/19/14.
//  Copyright (c) 2014 Christopher Ballinger. All rights reserved.
//

#import "XMPPService.h"

@interface XMPPService()
@property (nonatomic) NSUInteger testIncrement;
@end

@implementation XMPPService

// This implements the example protocol. Replace the body of this class with the implementation of this service's protocol.
- (void)upperCaseString:(NSString *)aString withReply:(void (^)(NSString *upperCaseString, NSUInteger testIncrement))reply {
    NSString *response = [aString uppercaseString];
    _testIncrement++;
    reply(response, _testIncrement);
}

@end
