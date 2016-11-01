//
//  TorServiceProtocol.h
//  TorService
//
//  Created by Christopher Ballinger on 11/19/14.
//  Copyright (c) 2014 Christopher Ballinger. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TorServiceProtocol

- (void)setupWithCompletion:(void(^ _Nonnull )(NSString * _Nullable socksHost, NSUInteger socksPort, NSError * _Nullable error))completion;
    
@end
