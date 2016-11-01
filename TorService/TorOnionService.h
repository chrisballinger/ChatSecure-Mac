//
//  TorOnionService.h
//  ChatSecure
//
//  Created by Chris Ballinger on 10/31/16.
//  Copyright © 2016 Christopher Ballinger. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface TorOnionServicePort : NSObject
@property (nonatomic, strong, readonly) NSString *address;
@property (nonatomic, readonly) uint16_t externalPort;
@property (nonatomic, readonly) uint16_t internalPort;

- (instancetype) initWithAddress:(NSString*)address
                    externalPort:(uint16_t)externalPort
                    internalPort:(uint16_t)internalPort;

@end

@interface TorOnionService : NSObject
@property (nonatomic, strong, readonly) NSString *serviceDirectory;
@property (nonatomic, strong, readonly) NSArray <TorOnionServicePort*> *portMappings;

- (instancetype) initWithServiceDirectory:(NSString*)serviceDirectory
                             portMappings:(NSArray <TorOnionServicePort*> *)portMappings;

@end
NS_ASSUME_NONNULL_END
