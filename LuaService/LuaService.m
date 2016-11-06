//
//  LuaService.m
//  LuaService
//
//  Created by Chris Ballinger on 10/29/16.
//  Copyright © 2016 Christopher Ballinger. All rights reserved.
//

#import "LuaService.h"

#define LUA_ERROR_DOMAIN @"lua.internal.prosody.err"
#define LUASERVICE_DOMAIN @"LuaService.Prosody"

@import lua51;

@interface LuaService()
@property (nonatomic, readonly) lua_State *L;
@end

@implementation LuaService
@synthesize L;


- (void) dealloc {

    [self terminate];
}

- (void) terminate {
    if (L) {
        lua_close(L);
        L = NULL;
    }
    [[NSProcessInfo processInfo] enableAutomaticTermination:@"lua"];
}



- (instancetype) init {
    if (self = [super init]) {
        [NSProcessInfo processInfo].automaticTerminationSupportEnabled = YES;
        [[NSProcessInfo processInfo] disableAutomaticTermination:@"lua"];
        /*
         * All Lua contexts are held in this structure. We work with it almost
         * all the time.
         */
        L = luaL_newstate();
        luaL_openlibs(L); /* Load Lua libraries */
    }
    return self;
}

- (void)runProsody:(void (^)(BOOL success,  NSError* _Nullable error))completion {
    NSString *scriptPath = [[self class] prosodyExe];
    NSError *error = nil;
    BOOL status = [[self class] runScript:scriptPath luaState:L error:&error];
    completion(status, error);
}

#pragma mark Configuration Script Generation

+ (BOOL)generateSelfSignedCertForDomain:(NSString*)domain error:(NSError**)error {
    // setup internal Lua
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);
    
    NSString *scriptPath = [[self class] prosodyCtl];
    
    // Set script arguments
    // http://lua-users.org/lists/lua-l/2007-07/msg00276.html
    lua_newtable(L);
    NSArray<NSString*> *args = @[@"prosodyctl", @"cert", @"generate", domain];
    [args enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        lua_pushstring(L, [obj UTF8String]);
        lua_rawseti(L, -2, (int)idx);
    }];
    lua_setglobal(L, "arg");
    
    BOOL result = [self runScript:scriptPath luaState:L error:error];
    
    lua_close(L);
    return result;
}


- (void)generateConfigurationWithOnionAddress:(NSString*)onionAddress allowRegistration:(BOOL)allowRegistration completion:(void (^)(BOOL success,  NSError* _Nullable error))completion {
    // Remove whitespace
    onionAddress = [onionAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *templatePath = [bundle pathForResource:@"prosody.cfg.lua" ofType:@"template"];
    NSParameterAssert(templatePath != nil);
    if (!templatePath) {
        completion(NO, [[self class] errorWithDescription:@"No prosody.cfg.lua template" code:2]);
        return;
    }
    NSError *error = nil;
    NSString *template = [NSString stringWithContentsOfFile:templatePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        completion(NO, error);
        return;
    }
    NSString *allowRegistrationStr = @"false";
    if (allowRegistration) {
        allowRegistrationStr = @"true";
    }
    template = [template stringByReplacingOccurrencesOfString:@"<<ALLOW_REGISTRATION>>" withString:allowRegistrationStr];
    NSString *tlsCertPath = [[self class] tlsCertPathForDomain:onionAddress];
    NSString *tlsKeyPath = [[self class] tlsKeyPathForDomain:onionAddress];
    template = [template stringByReplacingOccurrencesOfString:@"<<TLS_CERT_PATH>>" withString:tlsCertPath];
    template = [template stringByReplacingOccurrencesOfString:@"<<TLS_KEY_PATH>>" withString:tlsKeyPath];
    template = [template stringByReplacingOccurrencesOfString:@"<<ONION_ADDRESS>>" withString:onionAddress];
    
    BOOL result = [template writeToFile:[[self class] configurationPath] atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        completion(result, error);
        return;
    }
    
    // Check if certs exist, if not, generate certs
    if (![[NSFileManager defaultManager] fileExistsAtPath:tlsCertPath] ||
        ![[NSFileManager defaultManager] fileExistsAtPath:tlsKeyPath]) {
        result = [[self class] generateSelfSignedCertForDomain:onionAddress error:&error];
        if (error) {
            completion(result, error);
            return;
        }
    }
    completion(YES, nil);
}

#pragma mark prosody/prosodyctl runner

+ (BOOL)runScript:(NSString*)scriptPath luaState:(lua_State*)luaState error:(NSError**)error  {
    NSString *containingDir = [[self class] prosodyContainerDir];
    /* Load the file containing the script we are going to run */
    int status = luaL_loadfile(luaState, [scriptPath UTF8String]);
    if (status) {
        NSError *err = [self handleLuaErrorStatus:status message:@"Couldn't load" luaState:luaState];
        if (error) {
            *error = err;
        }
        return NO;
    }
    
    // Setup Prosody executables directory
    lua_pushstring(luaState, [containingDir UTF8String]);
    lua_setglobal(luaState, "CONTAINER_DIR");
    
    // Setup Prosody saved data directory
    NSString *dataDir = [[self class] dataPath];
    lua_pushstring(luaState, [dataDir UTF8String]);
    lua_setglobal(luaState, "CFG_DATADIR");
    
    // Set dir path for prosody.cfg.lua
    NSString *cfgDir = [[self class] dataPath];
    lua_pushstring(luaState, [cfgDir UTF8String]);
    lua_setglobal(luaState, "CFG_CONFIGDIR");
    
    /* Ask Lua to run our little script */
    int result = lua_pcall(luaState, 0, LUA_MULTRET, 0);
    if (result) {
        NSError *err = [self handleLuaErrorStatus:result message:@"Failed to run script" luaState:luaState];
        if (error) {
            *error = err;
        }
        return NO;
    }
    return YES;
}


#pragma mark Path Utilities

+ (NSString*) prosodyExe {
    return [[self prosodyBinDirectory] stringByAppendingPathComponent:@"prosody"];
}

+ (NSString*) prosodyCtl {
    return [[self prosodyBinDirectory] stringByAppendingPathComponent:@"prosodyctl"];
}

+ (NSString*)prosodyContainerDir {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *dir = [[bundle bundlePath] stringByAppendingPathComponent:@"Contents/Resources/prosody"];
    return dir;
}

+ (NSString*)prosodyBinDirectory {
    NSString *path = [[self prosodyContainerDir] stringByAppendingPathComponent:@"bin"];
    return path;
}

/** Path for prosody.cfg.lua generated from template file */
+ (NSString*) configurationPath {
    NSString *cfgPath = [[self dataPath] stringByAppendingPathComponent:@"prosody.cfg.lua"];
    return cfgPath;
}

/** Directory containing TLS .crt and .key */
+ (NSString*) tlsDirectory {
    return [self dataPath];
}

+ (NSString*) tlsCertPathForDomain:(NSString*)domain {
    NSString *name = [domain stringByAppendingPathExtension:@"crt"];
    NSString *crt = [[self dataPath] stringByAppendingPathComponent:name];
    return crt;
}

+ (NSString*) tlsKeyPathForDomain:(NSString*)domain {
    NSString *name = [domain stringByAppendingPathExtension:@"key"];
    NSString *key = [[self dataPath] stringByAppendingPathComponent:name];
    return key;
}

/** General data storage directory https://prosody.im/doc/configure#general_server_settings */
+ (NSString*) dataPath {
    NSURL *docs = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *dir = [[docs path] stringByAppendingPathComponent:LUASERVICE_DOMAIN];
    if(![[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:NULL]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
        NSLog(@"Error creating dataPath: %@", error);
    }
    return dir;
}


#pragma mark Error Handling

+ (NSError*) handleLuaErrorStatus:(int)status message:(NSString*)message luaState:(lua_State*)luaState {
    /* If something went wrong, error message is at the top of */
    /* the stack */
    const char *err = lua_tostring(luaState, -1);
    NSString *errStr = [[NSString alloc] initWithUTF8String:err];
    NSError *error = [NSError errorWithDomain:LUA_ERROR_DOMAIN code:status userInfo:@{NSLocalizedDescriptionKey: errStr,
                                                                                      NSLocalizedFailureReasonErrorKey: message}];
    NSLog(@"error: %@", error);
    return error;
}

+ (NSError*) errorWithDescription:(NSString*)description code:(NSInteger)code {
    return [NSError errorWithDomain:LUASERVICE_DOMAIN code:code userInfo:@{NSLocalizedFailureReasonErrorKey: description}];
}

@end
