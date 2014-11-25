//
//  OTRAppDelegate.m
//  ChatSecure
//
//  Created by Christopher Ballinger on 11/19/14.
//  Copyright (c) 2014 Christopher Ballinger. All rights reserved.
//

#import "OTRAppDelegate.h"
#import "XMPPServiceManager.h"
#import "OTRSecrets.h"

#import "DDLog.h"
#import "DDTTYLogger.h"


@interface OTRAppDelegate ()
@property (nonatomic, weak) IBOutlet NSWindow *window;

@property (nonatomic, strong, readonly) XMPPServiceManager *serviceManager;
@end

@implementation OTRAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    _serviceManager = [[XMPPServiceManager alloc] init];
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    [self.serviceManager connectWithJID:kXMPPTestAccountJID password:kXMPPTestAccountPassword];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
