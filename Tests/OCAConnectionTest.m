//
//  OCAConnectionTest.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAConnection.h"
#import "OCACommand.h"
#import "OCATimer.h"
#import "OCABridge.h"
#import "OCAHub.h"
#import "OCASubscriber.h"
#import "OCASemaphore.h"



@interface OCAConnectionTest : XCTestCase

@end





@implementation OCAConnectionTest



- (void)setUp {
    [super setUp];
}


- (void)tearDown {
    [super tearDown];
}





- (void)test_simpleConnection_objectsMustBeIdentical {
    id sentValue = @"Sent";
    __block id receivedValue = @"Received";
    
    OCACommand *command = [OCACommand new];
    [command connectTo:[OCASubscriber value:^(id value) {
        receivedValue = value;
    }]];
    
    [command sendValue:sentValue];
    
    XCTAssertTrue(sentValue == receivedValue, @"Received different value.");
}


- (void)test_OCATimer_periodicProductionOfDatesOfLimitedCount {
    OCATimer *timer = [[OCATimer alloc] initWithDelay:0 interval:0.01 leeway:0 count:10];
    OCASemaphore *semaphore = [[OCASemaphore alloc] init];
    __block NSUInteger tickCount = 0;
    
    [timer subscribe:^(id value) {
        NSLog(@"Start");
        tickCount ++;
        NSLog(@"End %lu", (unsigned long)tickCount);
    } finish:^(NSError *error) {
        [semaphore signal];
    }];
    
    BOOL signaled = [semaphore waitFor:10];
    XCTAssertTrue(signaled, @"Timer didn't end in given time.");
    XCTAssertEqual(tickCount, timer.count, @"Timer didn't fire required number of times.");
}


- (void)test_OCABridge_splitConsumers {
    /*     ,-C1
          /
     P---B---C2
          \
           '-C3
     */
    
    NSString *hello = @"Hello";
    OCACommand *producer = [OCACommand new];
    OCABridge *bridge = [OCABridge new];
    [producer connectTo:bridge];
    
    __block BOOL consumer1 = NO;
    [bridge subscribe:^(id value) {
        consumer1 = (value == hello);
    }];
    __block BOOL consumer2 = NO;
    [bridge subscribe:^(id value) {
        consumer2 = (value == hello);
    }];
    __block BOOL consumer3 = NO;
    [bridge subscribe:^(id value) {
        consumer3 = (value == hello);
    }];
    
    [producer sendValue:hello];
    XCTAssertTrue(consumer1 && consumer2 && consumer3, @"All three consumers must receive the original object.");
}


- (void)test_OCAHub_joinProducers {
    /*  P1-,
            \
        P2---H---C
            /
        P3-'
     */
    
    OCACommand *producer1 = [OCACommand new];
    OCACommand *producer2 = [OCACommand new];
    OCACommand *producer3 = [OCACommand new];
    NSArray *producers = @[ producer1, producer2, producer3 ];
    OCAHub *hubMerge = [OCAHub merge:producers];
    OCAHub *hubCombine = [OCAHub combine:producers];
    
    NSMutableArray *merged = [NSMutableArray array];
    [hubMerge subscribe:^(id value) {
        [merged addObject:value];
    }];
    
    NSMutableArray *combined = [NSMutableArray array];
    [hubCombine subscribe:^(NSArray *value) {
        [combined setArray:value];
    }];
    
    [producer1 sendValue:@"A"];
    [producer2 sendValue:@"B"];
    [producer3 sendValue:@"C"];
    
    NSArray *expected = @[ @"A", @"B", @"C" ];
    XCTAssertEqualObjects(merged, expected, @"Objects received one after another.");
    XCTAssertEqualObjects(combined, expected, @"Objects received at once");
}





@end
