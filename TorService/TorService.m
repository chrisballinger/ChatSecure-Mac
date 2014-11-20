//
//  TorService.m
//  TorService
//
//  Created by Christopher Ballinger on 11/19/14.
//  Copyright (c) 2014 Christopher Ballinger. All rights reserved.
//

#import "TorService.h"

@implementation TorService

// This implements the example protocol. Replace the body of this class with the implementation of this service's protocol.
- (void)upperCaseString:(NSString *)aString withReply:(void (^)(NSString *))reply {
    NSString *response = [aString uppercaseString];
    reply(response);
}

@end
