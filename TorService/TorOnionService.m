//
//  TorOnionService.m
//  ChatSecure
//
//  Created by Chris Ballinger on 10/31/16.
//  Copyright © 2016 Christopher Ballinger. All rights reserved.
//

#import "TorOnionService.h"

@implementation TorOnionServicePort

- (instancetype) initWithAddress:(NSString *)address externalPort:(uint16_t)externalPort internalPort:(uint16_t)internalPort {
    if (self = [super init]) {
        _address = address;
        _internalPort = internalPort;
        _externalPort = externalPort;
    }
    return self;
}

@end

@implementation TorOnionService

- (instancetype) initWithServiceDirectory:(NSString*)serviceDirectory
                             portMappings:(NSArray <TorOnionServicePort*> *)portMappings {
    if (self = [super init]) {
        _serviceDirectory = serviceDirectory;
        _portMappings = portMappings;
    }
    return self;
}

@end
