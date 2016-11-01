//
//  TorServiceProtocol.h
//  TorService
//
//  Created by Christopher Ballinger on 11/19/14.
//  Copyright (c) 2014 Christopher Ballinger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TorOnionService.h"

@protocol TorServiceProtocol

- (void)setupWithCompletion:(void(^ _Nonnull )(NSString * _Nullable socksHost, NSUInteger socksPort, NSString * _Nullable onionService, NSError * _Nullable error))completion internalPort:(uint16_t)internalPort externalPort:(uint16_t)externalPort serviceDirectoryName:(NSString * _Nonnull)serviceDirectoryName;
    
@end
