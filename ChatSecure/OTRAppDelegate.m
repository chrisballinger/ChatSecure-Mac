//
//  OTRAppDelegate.m
//  ChatSecure
//
//  Created by Christopher Ballinger on 11/19/14.
//  Copyright (c) 2014 Christopher Ballinger. All rights reserved.
//

#import "OTRAppDelegate.h"
#import "XMPPServiceProtocol.h"

@interface OTRAppDelegate ()
@property (weak) IBOutlet NSWindow *window;

@property (nonatomic, strong, readonly) NSMutableSet *xmppServiceConnections;
@end

@implementation OTRAppDelegate

- (NSXPCConnection*) newXMPPServiceConnection {
    NSXPCConnection *xmppServiceConnection = [[NSXPCConnection alloc] initWithServiceName:@"com.chrisballinger.XMPPService"];
    xmppServiceConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(XMPPServiceProtocol)];
    return xmppServiceConnection;
}

- (void) connectSecondService {
    
}

- (void) testXMPPService:(NSXPCConnection*)serviceConnection {
    [[serviceConnection remoteObjectProxy] upperCaseString:@"hello" withReply:^(NSString *aString, NSUInteger testIncrement) {
        // We have received a response. Update our text field, but do it on the main thread.
        NSLog(@"Result string was: %@, %lu for %@", aString, testIncrement, serviceConnection);
    }];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    _xmppServiceConnections = [NSMutableSet set];
    
    for (NSUInteger i = 0; i < 5; i++) {
        [self.xmppServiceConnections addObject:[self newXMPPServiceConnection]];
    }
    
    [self.xmppServiceConnections enumerateObjectsUsingBlock:^(NSXPCConnection *xmppServiceConnection, BOOL *stop) {
        [xmppServiceConnection resume];
        [self testXMPPService:xmppServiceConnection];
        [self testXMPPService:xmppServiceConnection];
    }];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
