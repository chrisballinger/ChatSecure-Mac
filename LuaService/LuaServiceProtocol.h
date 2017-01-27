//
//  LuaServiceProtocol.h
//  LuaService
//
//  Created by Chris Ballinger on 10/29/16.
//  Copyright © 2016 Christopher Ballinger. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
// The protocol that this service will vend as its API. This header file will also need to be visible to the process hosting the service.
@protocol LuaServiceProtocol

/** Path for prosody.cfg.lua generated from template file */
+ (NSString*) configurationPath;

/** Directory containing TLS .crt and .key */
+ (NSString*) tlsDirectory;
+ (NSString*) tlsCertPathForDomain:(NSString*)domain;
+ (NSString*) tlsKeyPathForDomain:(NSString*)domain;

/** General data storage directory https://prosody.im/doc/configure#general_server_settings */
+ (NSString*) dataPath;

/** Create prosody.cfg.lua from template. Will generate certs if not present. */
- (void)generateConfigurationWithOnionAddress:(NSString*)onionAddress allowRegistration:(BOOL)allowRegistration completion:(void (^)(BOOL success,  NSError* _Nullable error))completion;

/** Runs Prosody. Make sure to call generateConfiguration first, every time. */
- (void)runProsody:(void (^)(BOOL success,  NSError* _Nullable error))completion;


- (void) terminate;
    
@end

NS_ASSUME_NONNULL_END
