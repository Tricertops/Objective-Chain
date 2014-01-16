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
#import "OCAMulticast.h"
#import "OCATransformer.h"
#import "OCASemaphore.h"
#import "OCAQueue.h"
#import "OCAFilter.h"



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
    
    OCACommand *command = [OCACommand class:[NSString class]];
    [command subscribe:[NSString class] handler:^(id value) {
        receivedValue = value;
    }];
    
    [command sendValue:sentValue];
    
    XCTAssertTrue(sentValue == receivedValue, @"Received different value.");
}


- (void)test_simpleConnection_connectingToFinishedProducer {
    OCACommand *command = [OCACommand new];
    [command finishWithError:nil];
    
    __block BOOL finished = NO;
    [command subscribe:nil handler:nil finish:^(NSError *error) {
        finished = YES;
    }];
    
    XCTAssertTrue(finished, @"Connection immediately closed.");
}


- (void)test_simpleConnection_disabled {
    OCACommand *command = [OCACommand class:[NSString class]];
    
    NSMutableArray *received = [[NSMutableArray alloc] init];
    OCAConnection *connection = [command subscribe:nil handler:^(id value) {
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
    OCACommand *command = [OCACommand class:[NSString class]];
    NSMutableArray *received = [[NSMutableArray alloc] init];
    
    [[command
      filter:[NSPredicate predicateWithFormat:@"self BEGINSWITH[c] 'a'"]]
     transform:[OCATransformer access:OCAKeyPath(NSString, uppercaseString, NSString)]
     connectTo:[OCASubscriber class:[NSString class] handler:
                ^(NSString *value) {
                    [received addObject:value];
                }]];
    
    [command sendValues:@[ @"Auto", @"Magic", @"All", @"Every", @"Alien" ]];
    NSArray *expected = @[ @"AUTO",           @"ALL",           @"ALIEN" ];
    XCTAssertEqualObjects(received, expected, @"Should receive uppercase string that begins with A.");
}


- (void)test_OCATimer_periodicProductionOfDatesOfLimitedCount {
    OCATimer *timer = [OCATimer backgroundTimerWithInterval:0.1 until:[NSDate dateWithTimeIntervalSinceNow:1.1]];
    OCASemaphore *semaphore = [[OCASemaphore alloc] init];
    __block NSUInteger tickCount = 0;
    
    [timer
     onQueue:timer.queue
     transform:nil
     connectTo:[OCASubscriber
                class:[NSDate class]
                handler:^(NSDate *value) {
                    tickCount ++;
                } finish:^(NSError *error) {
                    [semaphore signal];
                }]];
    
    BOOL signaled = [semaphore waitFor:2];
    XCTAssertTrue(signaled, @"Timer didn't end in given time.");
    XCTAssertTrue(tickCount >= 10, @"Timer didn't fire required number of times.");
}


- (void)test_OCABridge_splitConsumers {
    /*     ,-C1
          /
     P---B---C2
          \
           '-C3
     */
    
    NSString *hello = @"Hello";
    OCACommand *producer = [OCACommand class:[NSString class]];
    OCABridge *bridge = [OCABridge bridgeForClass:[NSString class]];
    [producer connectTo:bridge];
    
    __block BOOL consumer1 = NO;
    [bridge subscribe:[NSString class] handler:^(id value) {
        consumer1 = (value == hello);
    }];
    __block BOOL consumer2 = NO;
    [bridge subscribe:[NSString class] handler:^(id value) {
        consumer2 = (value == hello);
    }];
    __block BOOL consumer3 = NO;
    [bridge subscribe:[NSString class] handler:^(id value) {
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
    
    OCACommand *producer1 = [OCACommand class:[NSString class]];
    OCACommand *producer2 = [OCACommand class:[NSString class]];
    OCACommand *producer3 = [OCACommand class:[NSString class]];
    NSArray *producers = @[ producer1, producer2, producer3 ];
    OCAHub *hubMerge = [OCAHub merge:producers];
    XCTAssertEqualObjects(hubMerge.valueClass, [NSString class], @"Merging hub should know class.");
    OCAHub *hubCombine = [OCAHub combine:producers];
    XCTAssertEqualObjects(hubCombine.valueClass, [NSArray class], @"Combining hub must produce arrays.");
    
    NSMutableArray *merged = [NSMutableArray array];
    [hubMerge subscribe:[NSString class] handler:^(id value) {
        [merged addObject:value];
    }];
    
    NSMutableArray *combined = [NSMutableArray array];
    [hubCombine subscribe:[NSArray class] handler:^(NSArray *value) {
        [combined setArray:value];
    }];
    
    [producer1 sendValue:@"A"];
    [producer2 sendValue:@"B"];
    [producer3 sendValue:@"C"];
    
    NSArray *expected = @[ @"A", @"B", @"C" ];
    XCTAssertEqualObjects(merged, expected, @"Objects received one after another.");
    XCTAssertEqualObjects(combined, expected, @"Objects received at once");
}


- (void)test_classValidation_creatingIncompatible {
    OCACommand *command = [OCACommand class:[NSString class]];
    
    OCAConnection *connection = [command subscribe:[NSNumber class] handler:nil];
    XCTAssertNil(connection, @"Connection cannot be created with incompatible classes, yet.");
    
    OCATransformer *transformer = [[OCATransformer pass] specializeFromClass:[NSArray class] toClass:nil];
    OCAConnection *transformedConnection = [command transform:transformer connectTo:[OCABridge bridge]];
    XCTAssertNil(transformedConnection, @"Connection cannot be created with incompatible classes, yet.");
}


- (void)test_classValidation_sendWrongClass {
    OCACommand *command = [OCACommand class:[NSString class]];
    
    NSMutableArray *received = [[NSMutableArray alloc] init];
    [command subscribe:[NSString class] handler:^(id value) {
        [received addObject:value];
    }];
    
    [command sendValue:@"A"];
    [command sendValue:@4];
    
    XCTAssertEqualObjects(received, @[ @"A" ], @"Should not receive while connection is disabled.");
}


- (void)test_simpleHubWithBridge {
    OCACommand *stringCommand = [OCACommand class:[NSString class]];
    OCACommand *numberCommand = [OCACommand class:[NSNumber class]];
    OCAHub *hub = [[stringCommand
                    bridgeWithTransform:[OCATransformer access:OCAKeyPath(NSString, length, NSUInteger)]]
                   mergeWith:numberCommand];
    
    NSMutableArray *received = [[NSMutableArray alloc] init];
    [hub subscribe:[NSNumber class] handler:^(NSNumber *value) {
        [received addObject:value];
    }];
    
    [stringCommand sendValue:@"12345"];
    [numberCommand sendValue:@5];
    
    NSArray *expected = @[ @5, @5 ];
    XCTAssertEqualObjects(received, expected, @"Expected transformed merged values.");
}


- (void)test_multicast {
    OCACommand *command = [OCACommand new];
    
    NSMutableArray *receivedStrings = [[NSMutableArray alloc] init];
    NSMutableArray *receivedNumbers = [[NSMutableArray alloc] init];
    
    [command multicast:
     [OCASubscriber class:[NSString class] handler:
      ^(NSString *value) {
          [receivedStrings addObject:value];
      }],
     [OCASubscriber class:[NSNumber class] handler:
      ^(NSNumber *value) {
          [receivedNumbers addObject:value];
      }], nil];
    
    [command sendValue:@"5"];
    [command sendValue:@5];
    
    XCTAssertEqualObjects(receivedStrings, @[ @"5" ], @"Expected only strings.");
    XCTAssertEqualObjects(receivedNumbers, @[ @5 ], @"Expected only numbers.");
}


//TODO: Wonder why this is so indeterministic.

//- (void)test_OCATimer_withConnectionOnDifferentQueue {
//    OCATimer *timer = [OCATimer backgroundTimerWithInterval:0.1 until:[NSDate dateWithTimeIntervalSinceNow:1.1]];
//    OCAQueue *queue = [OCAQueue serialQueue:@"Testing Queue"];
//    OCASemaphore *semaphore = [[OCASemaphore alloc] init];
//    __block NSUInteger tickCount = 0;
//    
//    [timer connectOn:queue
//              filter:[NSPredicate predicateWithValue:YES]
//           transform:[OCATransformer access:OCAKeyPath(NSDate, timeIntervalSinceNow, NSTimeInterval)]
//                  to:[OCASubscriber subscribeClass:[NSNumber class] handler:
//                      ^(NSNumber *timeInterval) {
//                          tickCount++;
//                      } finish:^(NSError *error) {
//                          NSLog(@"Heisenbug");
//                          [semaphore signal];
//                      }]];
//    
//    BOOL signaled = [semaphore waitFor:2];
//    XCTAssertTrue(signaled, @"Timer didn't end in given time.");
//    XCTAssertTrue(tickCount >= 10, @"Timer didn't fire required number of times.");
//}





@end
