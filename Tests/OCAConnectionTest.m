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
#import "OCATransformer.h"
#import "OCATransformer+Predefined.h"
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
    
    OCACommand *command = [OCACommand commandForClass:[NSString class]];
    [command subscribe:^(id value) {
        receivedValue = value;
    }];
    
    [command sendValue:sentValue];
    
    XCTAssertTrue(sentValue == receivedValue, @"Received different value.");
}


- (void)test_simpleConnection_connectingToFinishedProducer {
    OCACommand *command = [OCACommand command];
    [command finishWithError:nil];
    
    __block BOOL finished = NO;
    [command subscribe:^(id value) {
        
    } finish:^(NSError *error) {
        finished = YES;
    }];
    
    XCTAssertTrue(finished, @"Connection immediately closed.");
}


- (void)test_simpleConnection_disabled {
    OCACommand *command = [OCACommand commandForClass:[NSString class]];
    
    NSMutableArray *received = [[NSMutableArray alloc] init];
    OCAConnection *connection = [command subscribe:^(id value) {
        [received addObject:value];
    }];
    
    [command sendValue:@"A"];
    connection.enabled = NO;
    [command sendValue:@"B"];
    connection.enabled = YES;
    [command sendValue:@"C"];
    
    NSArray *expected = @[ @"A", @"C" ];
    XCTAssertEqualObjects(received, expected, @"Should not receive while connection is disabled.");
}


- (void)test_simpleConnection_withFilterAndTransform {
    OCACommand *command = [OCACommand commandForClass:[NSString class]];
    NSMutableArray *received = [[NSMutableArray alloc] init];
    
    [command connectWithFilter:[NSPredicate predicateWithFormat:@"self BEGINSWITH[c] 'a'"]
                     transform:[OCATransformer accessKeyPath:OCAKeypath(NSString, uppercaseString)]
                            to:[OCASubscriber subscribe:
                                ^(id value) {
                                    [received addObject:value];
                                }]];
    
    [command sendValues:@[ @"Auto", @"Magic", @"All", @"Every", @"Alien" ]];
    NSArray *expected = @[ @"AUTO",           @"ALL",           @"ALIEN" ];
    XCTAssertEqualObjects(received, expected, @"Should receive uppercase string that begins with A.");
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
    OCACommand *producer = [OCACommand commandForClass:[NSString class]];
    OCABridge *bridge = [OCABridge bridgeForClass:[NSString class]];
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
    
    OCACommand *producer1 = [OCACommand commandForClass:[NSString class]];
    OCACommand *producer2 = [OCACommand commandForClass:[NSString class]];
    OCACommand *producer3 = [OCACommand commandForClass:[NSString class]];
    NSArray *producers = @[ producer1, producer2, producer3 ];
    OCAHub *hubMerge = [OCAHub merge:producers];
    XCTAssertEqualObjects(hubMerge.valueClass, [NSString class], @"Merging hub should know class.");
    OCAHub *hubCombine = [OCAHub combine:producers];
    XCTAssertEqualObjects(hubCombine.valueClass, [NSArray class], @"Combining hub must produce arrays.");
    
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


- (void)test_classValidation_sendWrongClass {
    OCACommand *command = [OCACommand commandForClass:[NSString class]];
    
    NSMutableArray *received = [[NSMutableArray alloc] init];
    [command subscribe:^(id value) {
        [received addObject:value];
    }];
    
    [command sendValue:@"A"];
    [command sendValue:@4];
    
    XCTAssertEqualObjects(received, @[ @"A" ], @"Should not receive while connection is disabled.");
}





@end
