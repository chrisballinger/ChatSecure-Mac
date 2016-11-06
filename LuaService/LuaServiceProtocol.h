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

/*
 To use the service from an application or other process, use NSXPCConnection to establish a connection to the service by doing something like this:

     _connectionToService = [[NSXPCConnection alloc] initWithServiceName:@"org.chatsecure.LuaService"];
     _connectionToService.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(LuaServiceProtocol)];
     [_connectionToService resume];

Once you have a connection to the service, you can use it like this:

     [[_connectionToService remoteObjectProxy] upperCaseString:@"hello" withReply:^(NSString *aString) {
         // We have received a response. Update our text field, but do it on the main thread.
         NSLog(@"Result string was: %@", aString);
     }];

 And, when you are finished with the service, clean up the connection like this:

     [_connectionToService invalidate];
*/
