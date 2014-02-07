//
//  OCAConnectionTest.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCACommand.h"
#import "OCATimer.h"
#import "OCABridge.h"
#import "OCAHub.h"
#import "OCASubscriber.h"
#import "OCATransformer.h"
#import "OCASemaphore.h"
#import "OCAQueue.h"
#import "OCAFilter.h"
#import "OCAContext.h"



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
    [command subscribeForClass:[NSString class] handler:^(id value) {
        receivedValue = value;
    }];
    
    [command sendValue:sentValue];
    
    XCTAssertTrue(sentValue == receivedValue, @"Received different value.");
}


- (void)test_simpleConnection_connectingToFinishedProducer {
    OCACommand *command = [OCACommand new];
    [command finishWithError:nil];
    
    __block BOOL finished = NO;
    [command subscribeForClass:nil handler:nil finish:^(NSError *error) {
        finished = YES;
    }];
    
    XCTAssertTrue(finished, @"Connection immediately closed.");
}


- (void)test_simpleConnection_withFilterAndTransform {
    OCACommand *command = [OCACommand commandForClass:[NSString class]];
    NSMutableArray *received = [[NSMutableArray alloc] init];
    
    [[[command
       filterValues:[NSPredicate predicateWithFormat:@"self BEGINSWITH[c] 'a'"]]
      transformValues:
      [OCATransformer access:OCAKeyPath(NSString, uppercaseString, NSString)],
      nil]
     subscribeForClass:[NSString class] handler:^(NSString *value) {
         [received addObject:value];
     }];
    
    [command sendValues:@[ @"Auto", @"Magic", @"All", @"Every", @"Alien" ]];
    NSArray *expected = @[ @"AUTO",           @"ALL",           @"ALIEN" ];
    XCTAssertEqualObjects(received, expected, @"Should receive uppercase string that begins with A.");
}


- (void)test_OCATimer_periodicProductionOfDatesOfLimitedCount {
    OCATimer *timer = [OCATimer backgroundTimerWithInterval:0.1 untilDate:[NSDate dateWithTimeIntervalSinceNow:1.1]];
    OCASemaphore *semaphore = [[OCASemaphore alloc] init];
    __block NSUInteger tickCount = 0;
    
    [[timer
     switchToQueue:timer.queue]
     subscribeForClass:[NSNumber class] handler:^(NSNumber *timeInterval) {
         tickCount ++;
     } finish:^(NSError *error) {
         [semaphore signal];
     }];
    
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
    OCACommand *producer = [OCACommand commandForClass:[NSString class]];
    OCABridge *bridge = [OCABridge bridgeForClass:[NSString class]];
    [producer connectTo:bridge];
    
    __block BOOL consumer1 = NO;
    [bridge subscribeForClass:[NSString class] handler:^(id value) {
        consumer1 = (value == hello);
    }];
    __block BOOL consumer2 = NO;
    [bridge subscribeForClass:[NSString class] handler:^(id value) {
        consumer2 = (value == hello);
    }];
    __block BOOL consumer3 = NO;
    [bridge subscribeForClass:[NSString class] handler:^(id value) {
        consumer3 = (value == hello);
    }];
    
    [producer sendValue:hello];
    XCTAssertTrue(consumer1 && consumer2 && consumer3, @"All three consumers must receive the original object.");
}


- (void)test_classValidation_creatingIncompatible {
    OCACommand *command = [OCACommand commandForClass:[NSString class]];
    
    [command subscribeForClass:[NSNumber class] handler:nil];
    XCTAssertTrue(command.consumers.count == 0, @"Connection cannot be created with incompatible classes, yet.");
}


- (void)test_classValidation_sendWrongClass {
    OCACommand *command = [OCACommand commandForClass:[NSString class]];
    
    NSMutableArray *received = [[NSMutableArray alloc] init];
    [command subscribeForClass:[NSString class] handler:^(id value) {
        [received addObject:value];
    }];
    
    [command sendValue:@"A"];
    [command sendValue:@4];
    
    XCTAssertEqualObjects(received, @[ @"A" ], @"Should not receive incompatible class.");
}


- (void)test_simpleHubWithBridge {
    OCACommand *stringCommand = [OCACommand commandForClass:[NSString class]];
    OCACommand *numberCommand = [OCACommand commandForClass:[NSNumber class]];
    OCAHub *hub = [[stringCommand transformValues:
                    [OCATransformer access:OCAKeyPath(NSString, length, NSUInteger)],
                    nil] mergeWith:numberCommand, nil];
    
    NSMutableArray *received = [[NSMutableArray alloc] init];
    [hub subscribeForClass:[NSNumber class] handler:^(NSNumber *value) {
        [received addObject:value];
    }];
    
    [stringCommand sendValue:@"12345"];
    [numberCommand sendValue:@5];
    
    NSArray *expected = @[ @5, @5 ];
    XCTAssertEqualObjects(received, expected, @"Expected transformed merged values.");
}


- (void)test_OCATimer_withConnectionOnDifferentQueue {
    OCATimer *timer = [OCATimer backgroundTimerWithInterval:0.1 untilDate:[NSDate dateWithTimeIntervalSinceNow:1.1]];
    OCAQueue *queue = [OCAQueue serialQueue:@"Testing Queue"];
    OCASemaphore *semaphore = [[OCASemaphore alloc] init];
    __block NSUInteger tickCount = 0;
    
    [[timer
      switchToQueue:queue]
     subscribeForClass:[NSNumber class] handler:^(NSNumber *timeInterval) {
         tickCount++;
     } finish:^(NSError *error) {
         [semaphore signal];
     }];
    
    BOOL signaled = [semaphore waitFor:2];
    XCTAssertTrue(signaled, @"Timer didn't end in given time.");
    XCTAssertTrue(tickCount == 10, @"Timer didn't fire required number of times.");
}





@end
