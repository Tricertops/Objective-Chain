//
//  OCAThrottleTest.m
//  Objective-Chain
//
//  Created by Martin Kiss on 2.2.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAThrottle.h"
#import "OCACommand.h"
#import "OCASubscriber.h"
#import "OCAQueue.h"
#import "OCASemaphore.h"





@interface OCAThrottleTest : XCTestCase

@end





@implementation OCAThrottleTest




- (void)test_nonContinuousThrottle {
    OCACommand *command = [OCACommand commandForClass:[NSNumber class]];
    
    NSMutableArray *received = [[NSMutableArray alloc] init];
    [[command throttle:0.05]
     subscribeForClass:[NSNumber class] handler:^(NSNumber *value) {
         @synchronized(received) {
             [received addObject:value];
         }
     }];
    OCASemaphore *semaphore = [[OCASemaphore alloc] initWithValue:0];
    
    [[OCAQueue background] performBlockAndWait:^{
        for (NSUInteger index = 0; index <= 100; index++) {
            [command sendValue:@(index)];
            [NSThread sleepForTimeInterval:0.01];
        }
        [[OCAQueue background] performAfter:0.1 block:^{
            [semaphore signal];
        }];
    }];
    
    BOOL signaled = [semaphore waitFor:2];
    XCTAssertTrue(signaled, @"Task didn't finish in time.");
    
    NSArray *expected = @[ @100 ];
    XCTAssertEqualObjects(received, expected, @"Should receive only last value.");
}


- (void)test_continuousThrottle {
    OCACommand *command = [OCACommand commandForClass:[NSNumber class]];
    
    NSMutableArray *received = [[NSMutableArray alloc] init];
    [[command throttleContinuous:0.1]
     subscribeForClass:[NSNumber class] handler:^(NSNumber *value) {
         @synchronized(received) {
             [received addObject:value];
         }
     }];
    OCASemaphore *semaphore = [[OCASemaphore alloc] initWithValue:0];
    
    [[OCAQueue background] performBlockAndWait:^{
        for (NSUInteger index = 0; index <= 100; index++) {
            [command sendValue:@(index)];
            [NSThread sleepForTimeInterval:0.01 + 0.0001]; // Give him some more time to have exactly 10th values.
        }
        [[OCAQueue background] performAfter:0.1 block:^{
            [semaphore signal];
        }];
    }];
    
    BOOL signaled = [semaphore waitFor:2];
    XCTAssertTrue(signaled, @"Task didn't finish in time.");
    
    NSArray *expected = @[ @0, @10, @20, @30, @40, @50, @60, @70, @80, @90, @100 ];
    XCTAssertEqualObjects(received, expected, @"Should receive a value every 0.1s, so every 10th.");
}




@end


