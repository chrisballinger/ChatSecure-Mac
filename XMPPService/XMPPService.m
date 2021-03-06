//
//  XMPPService.m
//  XMPPService
//
//  Created by Christopher Ballinger on 11/19/14.
//  Copyright (c) 2014 Christopher Ballinger. All rights reserved.
//

#import "XMPPService.h"
#import "XMPPServiceListener.h"
@import CocoaAsyncSocket;
@import XMPPFramework;

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_VERBOSE;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_INFO;
#endif


@interface XMPPService()
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
@property (nonatomic, strong, readonly) XMPPvCardCoreDataStorage *xmppvCardStorage;

@property (nonatomic, strong) NSString *password;

@end

@implementation XMPPService

- (instancetype) init {
    if (self = [super init]) {
        [self setupStream];
        [NSProcessInfo processInfo].automaticTerminationSupportEnabled = YES;
    }
    return self;
}

/** Wrapper around [parentConnection remoteObjectProxy] */
- (id<XMPPServiceListener>)xmppListener {
    return [self.parentConnection remoteObjectProxy];
}

- (void) updateConnectionStatus:(XMPPConnectionStatus)connectionStatus error:(NSError*)error {
    [self.xmppListener handleConnectionStatus:connectionStatus streamJID:self.xmppStream.myJID error:error streamTag:self.xmppStream.tag];
}

- (void) receivedMessage:(XMPPMessage*)message {
    [self.xmppListener handleIncomingMessage:message streamTag:self.xmppStream.tag];
}

#pragma mark XMPPServiceProtocol methods

/**
 *  Connects to XMPP server.
 *
 *  @param myJID    Jabber ID e.g. user@example.com
 *  @param password plaintext password
 *  @param completionBlock does not reflect full connection state, see setConnectionStatusBlock:
 */
- (void)connectWithJID:(NSString*)myJID
              password:(NSString*)password
       completionBlock:(void (^)(BOOL success, NSError *error))completionBlock {
    
    NSAssert(myJID.length > 0, @"myJID must have length");
    NSAssert(password.length > 0, @"password must have length");
    if (!myJID.length || !password.length) {
        completionBlock(NO, [NSError errorWithDomain:@"XMPPService" code:100 userInfo:@{NSLocalizedDescriptionKey: @"JID and password must have lengths"}]);
        return;
    }
    if (![self.xmppStream isDisconnected]) {
        completionBlock(YES, nil);
        return;
    }
    
    [self.xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
    self.password = password;
    
    NSError *error = nil;
    if (![self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    {
        XMPPLogWarn(@"Error connecting: %@", error);
        completionBlock(NO, error);
        return;
    }
    [[NSProcessInfo processInfo] disableAutomaticTermination:@"xmpp service"];
    completionBlock(YES, nil);
    [self updateConnectionStatus:XMPPConnectionStatusConnecting error:nil];
}

/**
 *  Disconnects from XMPP server.
 */
- (void)disconnect
{
    [[NSProcessInfo processInfo] enableAutomaticTermination:@"xmpp service"];
    [self goOffline];
    [self.xmppStream disconnect];
}

/**
 *  Creates and connects to a new account on XMPP server.
 *
 *  @param newJID   New Jabber ID e.g. user@example.com
 *  @param password plaintext password
 *  @param completionBlock does not reflect full connection state, see setConnectionStatusBlock:
 */
- (void)connectWithNewJID:(NSString*)newJID
                 password:(NSString*)password
          completionBlock:(void (^)(BOOL success, NSError *error))completionBlock {
    NSAssert(NO, @"Not implemented");
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setupStream
{
    NSAssert(_xmppStream == nil, @"Method setupStream invoked multiple times");
    
    // Setup xmpp stream
    //
    // The XMPPStream is the base class for all activity.
    // Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    
    _xmppStream = [[XMPPStream alloc] init];
    _xmppStream.tag = [[NSUUID UUID] UUIDString];
    
    // Setup reconnect
    //
    // The XMPPReconnect module monitors for "accidental disconnections" and
    // automatically reconnects the stream for you.
    // There's a bunch more information in the XMPPReconnect header file.
    
    _xmppReconnect = [[XMPPReconnect alloc] init];
    
    // Setup roster
    //
    // The XMPPRoster handles the xmpp protocol stuff related to the roster.
    // The storage for the roster is abstracted.
    // So you can use any storage mechanism you want.
    // You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
    // or setup your own using raw SQLite, or create your own storage mechanism.
    // You can do it however you like! It's your application.
    // But you do need to provide the roster with some storage facility.
    
    _xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
    
    _xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:self.xmppRosterStorage];
    
    self.xmppRoster.autoFetchRoster = YES;
    self.xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    // Setup vCard support
    //
    // The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
    // The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
    
    _xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    _xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:self.xmppvCardStorage];
    
    _xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:self.xmppvCardTempModule];
    
    // Setup capabilities
    //
    // The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
    // Basically, when other clients broadcast their presence on the network
    // they include information about what capabilities their client supports (audio, video, file transfer, etc).
    // But as you can imagine, this list starts to get pretty big.
    // This is where the hashing stuff comes into play.
    // Most people running the same version of the same client are going to have the same list of capabilities.
    // So the protocol defines a standardized way to hash the list of capabilities.
    // Clients then broadcast the tiny hash instead of the big list.
    // The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
    // and also persistently storing the hashes so lookups aren't needed in the future.
    //
    // Similarly to the roster, the storage of the module is abstracted.
    // You are strongly encouraged to persist caps information across sessions.
    //
    // The XMPPCapabilitiesCoreDataStorage is an ideal solution.
    // It can also be shared amongst multiple streams to further reduce hash lookups.
    
    _xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    _xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:self.xmppCapabilitiesStorage];
    
    self.xmppCapabilities.autoFetchHashedCapabilities = YES;
    self.xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    // Activate xmpp modules
    
    [self.xmppReconnect         activate:self.xmppStream];
    [self.xmppRoster            activate:self.xmppStream];
    [self.xmppvCardTempModule   activate:self.xmppStream];
    [self.xmppvCardAvatarModule activate:self.xmppStream];
    [self.xmppCapabilities      activate:self.xmppStream];
    
    // Add ourself as a delegate to anything we may be interested in
    
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)teardownStream
{
    [self.xmppStream removeDelegate:self];
    [self.xmppRoster removeDelegate:self];
    
    [self.xmppReconnect         deactivate];
    [self.xmppRoster            deactivate];
    [self.xmppvCardTempModule   deactivate];
    [self.xmppvCardAvatarModule deactivate];
    [self.xmppCapabilities      deactivate];
    
    [self.xmppStream disconnect];
    
    _xmppStream = nil;
    _xmppReconnect = nil;
    _xmppRoster = nil;
    _xmppRosterStorage = nil;
    _xmppvCardStorage = nil;
    _xmppvCardTempModule = nil;
    _xmppvCardAvatarModule = nil;
    _xmppCapabilities = nil;
    _xmppCapabilitiesStorage = nil;
}

// It's easy to create XML elments to send and to read received XML elements.
// You have the entire NSXMLElement and NSXMLNode API's.
//
// In addition to this, the NSXMLElement+XMPP category provides some very handy methods for working with XMPP.
//
// On the iPhone, Apple chose not to include the full NSXML suite.
// No problem - we use the KissXML library as a drop in replacement.
//
// For more information on working with XML elements, see the Wiki article:
// https://github.com/robbiehanson/XMPPFramework/wiki/WorkingWithElements

- (void)goOnline
{
    
    
    XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
    
    NSString *domain = [self.xmppStream.myJID domain];
    
    //Google set their presence priority to 24, so we do the same to be compatible.
    
    if([domain isEqualToString:@"gmail.com"]
       || [domain isEqualToString:@"gtalk.com"]
       || [domain isEqualToString:@"talk.google.com"])
    {
        NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
        [presence addChild:priority];
    }
    
    [[self xmppStream] sendElement:presence];
}

- (void)goOffline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    
    [[self xmppStream] sendElement:presence];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    XMPPLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
    XMPPLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    NSString *expectedCertName = [self.xmppStream.myJID domain];
    if (expectedCertName)
    {
        [settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
    }
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    XMPPLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    XMPPLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    NSError *error = nil;
    if (![[self xmppStream] authenticateWithPassword:self.password error:&error])
    {
        XMPPLogError(@"Error authenticating: %@", error);
    }
    [self updateConnectionStatus:XMPPConnectionStatusAuthenticating error:error];
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    XMPPLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    [self goOnline];
    
    [self updateConnectionStatus:XMPPConnectionStatusConnected error:nil];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    XMPPLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    [self disconnect];
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    XMPPLogVerbose(@"%@: %@ %@", THIS_FILE, THIS_METHOD, iq);
    
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    XMPPLogVerbose(@"%@: %@ %@", THIS_FILE, THIS_METHOD, message);
    
    [self receivedMessage:message];
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    XMPPLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    XMPPLogVerbose(@"%@: %@ %@", THIS_FILE, THIS_METHOD, error);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    if (error) {
        XMPPLogError(@"Unable to connect to server: %@", error);
    } else {
        XMPPLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    }
    
    [self updateConnectionStatus:XMPPConnectionStatusDisconnected error:error];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
    XMPPLogVerbose(@"%@: %@ %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
}



@end
