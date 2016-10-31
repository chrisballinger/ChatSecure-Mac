//
//  LuaService.m
//  LuaService
//
//  Created by Chris Ballinger on 10/29/16.
//  Copyright © 2016 Christopher Ballinger. All rights reserved.
//

#import "LuaService.h"

#define ERROR_DOMAIN @"prosody.err"

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

- (void)runProsody:(void (^)(NSString *result,  NSError* _Nullable error))completion {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *dir = [[bundle bundlePath] stringByAppendingPathComponent:@"Contents/Resources/prosody"];
    NSString *path = [dir stringByAppendingPathComponent:@"bin/prosody"];
    [self runPath:path containingDir:dir completion:completion];
}

- (void)runPath:(NSString*)scriptPath containingDir:(NSString*)containingDir completion:(void (^)(NSString *result,  NSError* _Nullable error))completion {
    /* Load the file containing the script we are going to run */
    int status = luaL_loadfile(L, [scriptPath UTF8String]);
    //int status = luaL_loadstring(L, [script UTF8String]);
    if (status) {
        [self handleErrorStatus:status message:@"Couldn't load" completion:completion];
        return;
    }
    
    lua_pushstring(L, [containingDir UTF8String]);
    lua_setglobal(L, "CONTAINER_DIR");
    
    /* Ask Lua to run our little script */
    int result = lua_pcall(L, 0, LUA_MULTRET, 0);
    if (result) {
        [self handleErrorStatus:result message:@"Failed to run script" completion:completion];
        return;
    }
    completion(@"", nil);
}

- (void) handleErrorStatus:(int)status message:(NSString*)message completion:(void (^)(NSString *result,  NSError* _Nullable error))completion {
    /* If something went wrong, error message is at the top of */
    /* the stack */
    const char *err = lua_tostring(L, -1);
    NSString *errStr = [[NSString alloc] initWithUTF8String:err];
    NSLog(@"%@: %@", message, errStr);
    NSError *error = [NSError errorWithDomain:ERROR_DOMAIN code:status userInfo:@{NSLocalizedDescriptionKey: errStr}];
    completion(errStr, error);
}

@end
