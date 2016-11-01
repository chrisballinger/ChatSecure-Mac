//
//  TorService.m
//  TorService
//
//  Created by Christopher Ballinger on 11/19/14.
//  Copyright (c) 2014 Christopher Ballinger. All rights reserved.
//

#import "TorService.h"
@import CPAProxy;

@interface TorService()
@property (nonatomic, strong, readonly) CPAProxyManager *torManager;
@end

@implementation TorService

- (void) dealloc {
    [[NSProcessInfo processInfo] enableAutomaticTermination:@"lua"];
}

- (instancetype) init {
    if (self = [super init]) {
        [NSProcessInfo processInfo].automaticTerminationSupportEnabled = YES;
        [[NSProcessInfo processInfo] disableAutomaticTermination:@"lua"];
        
        // Get resource paths for the torrc and geoip files from the main bundle
        NSBundle *cpaProxyFrameworkBundle = [NSBundle bundleForClass:[CPAProxyManager class]];
        NSURL *cpaProxyBundleURL = [cpaProxyFrameworkBundle URLForResource:@"CPAProxy" withExtension:@"bundle"];
        NSBundle *cpaProxyBundle = [[NSBundle alloc] initWithURL:cpaProxyBundleURL];
        NSParameterAssert(cpaProxyBundle != nil);
        
        //NSString *torrcPath = [[NSBundle mainBundle] pathForResource:@"torrc" ofType:nil]; // use custom torrc
        NSString *torrcPath = [cpaProxyBundle pathForResource:@"torrc" ofType:nil];
        NSString *geoipPath = [cpaProxyBundle pathForResource:@"geoip" ofType:nil];
        NSString *dataDirectory = [[[[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"com.ChatSecure.Tor"] path];
        
        // Initialize a CPAProxyManager
        CPAConfiguration *configuration = [CPAConfiguration configurationWithTorrcPath:torrcPath geoipPath:geoipPath torDataDirectoryPath:dataDirectory];
        configuration.isolateDestinationAddress = YES;
        configuration.isolateDestinationPort = YES;
        _torManager = [CPAProxyManager proxyWithConfiguration:configuration];
    }
    return self;
}

- (void)setupWithCompletion:(void(^)(NSString *socksHost, NSUInteger socksPort, NSError *error))completion {
    [self.torManager setupWithCompletion:completion progress:nil];
}

@end
