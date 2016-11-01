//
//  TorService.m
//  TorService
//
//  Created by Christopher Ballinger on 11/19/14.
//  Copyright (c) 2014 Christopher Ballinger. All rights reserved.
//

#import "TorService.h"
#import "TorOnionService.h"
@import CPAProxy;

@interface TorService()
@property (nonatomic, strong, readonly) CPAProxyManager *torManager;
@end

@implementation TorService

- (void) dealloc {
    [[NSProcessInfo processInfo] enableAutomaticTermination:@"tor"];
}

- (instancetype) init {
    if (self = [super init]) {
        [NSProcessInfo processInfo].automaticTerminationSupportEnabled = YES;
        [[NSProcessInfo processInfo] disableAutomaticTermination:@"tor"];
        
        
    }
    return self;
}

- (void)setupWithCompletion:(void(^ _Nonnull )(NSString * _Nullable socksHost, NSUInteger socksPort, NSString * _Nullable onionService, NSError * _Nullable error))completion internalPort:(uint16_t)internalPort externalPort:(uint16_t)externalPort serviceDirectoryName:(NSString *)serviceDirectoryName {
    if (_torManager) {
        completion(nil, 0, nil, [NSError errorWithDomain:@"TorService" code:0 userInfo:@{NSLocalizedFailureReasonErrorKey: @"Already setup."}]);
        return;
    }
    
    NSError *error = nil;
    // Get resource paths for the torrc and geoip files from the main bundle
    NSBundle *cpaProxyFrameworkBundle = [NSBundle bundleForClass:[CPAProxyManager class]];
    NSURL *cpaProxyBundleURL = [cpaProxyFrameworkBundle URLForResource:@"CPAProxy" withExtension:@"bundle"];
    NSBundle *cpaProxyBundle = [[NSBundle alloc] initWithURL:cpaProxyBundleURL];
    NSParameterAssert(cpaProxyBundle != nil);
    
    //NSString *torrcPath = [[NSBundle mainBundle] pathForResource:@"torrc" ofType:nil]; // use custom torrc
    NSString *torrcPath = [cpaProxyBundle pathForResource:@"torrc" ofType:nil];
    NSString *geoipPath = [cpaProxyBundle pathForResource:@"geoip" ofType:nil];
    NSURL *appSupport = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *dataDirectory = [[appSupport URLByAppendingPathComponent:@"com.ChatSecure.Tor"] path];
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:dataDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    
    // Load onion services into torrc
    NSURL *docs = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *hsDir = [[docs URLByAppendingPathComponent:serviceDirectoryName] path];
    TorOnionServicePort *portMapping = [[TorOnionServicePort alloc] initWithAddress:@"127.0.0.1" externalPort:externalPort internalPort:internalPort];
    TorOnionServicePort *xmppC2S = [[TorOnionServicePort alloc] initWithAddress:@"127.0.0.1" externalPort:5222 internalPort:5222];
    TorOnionService *onionService = [[TorOnionService alloc] initWithServiceDirectory:hsDir portMappings:@[portMapping, xmppC2S]];
    
    NSMutableString *torrcString = [[NSMutableString alloc] initWithContentsOfFile:torrcPath encoding:NSUTF8StringEncoding error:&error];
    [torrcString appendString:@"\n\n"];
    [torrcString appendFormat:@"HiddenServiceDir %@\n", hsDir];
    [onionService.portMappings enumerateObjectsUsingBlock:^(TorOnionServicePort * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [torrcString appendFormat:@"HiddenServicePort %d %@:%d\n", obj.externalPort, obj.address, obj.internalPort];
    }];
    [torrcString appendString:@"\n\n"];
    
    NSString *newTorrcPath = [dataDirectory stringByAppendingPathComponent:@"torrc"];
    success = [torrcString writeToFile:newTorrcPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    // Initialize a CPAProxyManager
    CPAConfiguration *configuration = [CPAConfiguration configurationWithTorrcPath:newTorrcPath geoipPath:geoipPath torDataDirectoryPath:dataDirectory];
    configuration.useDefaultSocksPort = YES;
    configuration.isolateDestinationAddress = YES;
    configuration.isolateDestinationPort = YES;
    _torManager = [CPAProxyManager proxyWithConfiguration:configuration];
    
    [self.torManager setupWithCompletion:^(NSString *socksHost, NSUInteger socksPort, NSError *error) {
        if (error) {
            completion(nil, 0, nil, error);
            return;
        }
        NSString *hsDir = onionService.serviceDirectory;
        NSString *hostnamePath = [hsDir stringByAppendingPathComponent:@"hostname"];
        NSString *hostname = [NSString stringWithContentsOfFile:hostnamePath encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            completion(nil, 0, nil, error);
            return;
        }
        completion(socksHost, socksPort, hostname, nil);
    } progress:nil];
}

@end
