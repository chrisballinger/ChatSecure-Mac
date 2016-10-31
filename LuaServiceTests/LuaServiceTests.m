//
//  LuaServiceTests.m
//  ChatSecure
//
//  Created by Chris Ballinger on 10/30/16.
//  Copyright © 2016 Christopher Ballinger. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LuaService.h"

@interface LuaServiceTests : XCTestCase

@end

@implementation LuaServiceTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testProsody {
    XCTestExpectation *exp = [self expectationWithDescription:@"prosody"];
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    LuaService *service = [[LuaService alloc] init];
    [service runScript:@"" completion:^(NSString * _Nonnull result, NSError * _Nullable error) {
        NSLog(@"Finished: %@", result);
        XCTAssertNil(error);
        if (error) {
            NSLog(@"error: %@", error);
        }
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"error: %@", error);
        }
    }];
}


@end
