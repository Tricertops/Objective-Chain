//
//  OCAQueueTest.m
//  Objective-Chain
//
//  Created by Martin Kiss on 6.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAQueue.h"
#import "OCASemaphore.h"



@interface OCAQueueTest : XCTestCase

@property (atomic, readwrite, strong) OCASemaphore *semaphore;

@end





@implementation OCAQueueTest




- (void)setUp {
    self.semaphore = [[OCASemaphore alloc] init];
}


- (void)tearDown {
    self.semaphore = nil;
}


- (void)heavyTask {
    for (NSUInteger i = 0; i < 100; i++) (void)[[NSDateFormatter alloc] init];
}





- (void)test_background_async {
    [[OCAQueue background] performBlock:^{
        [self.semaphore signal];
    }];
    BOOL signaled = [self.semaphore waitFor:10];
    XCTAssertTrue(signaled, @"Block didn't execute.");
}


- (void)test_background_sync {
    __block BOOL passed = NO;
    [[OCAQueue background] performBlockAndWait:^{
        passed = YES;
    }];
    XCTAssertTrue(passed, @"Block didn't execute synchronously.");
}


- (void)test_customBackgroundConcurrent {
    OCAQueue *queue = [[OCAQueue alloc] initWithName:@"Test" concurrent:YES targetQueue:[OCAQueue background]];
    
    [queue performBlock:^{
        XCTAssertEqualObjects(queue, [OCAQueue current]);
        [self.semaphore signal];
    }];
    BOOL signaled = [self.semaphore waitFor:10];
    XCTAssertTrue(signaled, @"Block didn't execute.");
    
    __block BOOL passed = NO;
    [queue performBlockAndWait:^{
        XCTAssertEqualObjects(queue, [OCAQueue current]);
        passed = YES;
    }];
    XCTAssertTrue(passed, @"Block didn't execute synchronously.");
}


- (void)test_inheritSerial {
    OCAQueue *firstQueue = [[OCAQueue alloc] initWithName:@"Test 1" concurrent:NO targetQueue:[OCAQueue background]];
    OCAQueue *secondQueue = [[OCAQueue alloc] initWithName:@"Test 2" concurrent:YES targetQueue:firstQueue];
    XCTAssertFalse(firstQueue.isConcurrent, @"Didn't create serial queue.");
    XCTAssertFalse(secondQueue.isConcurrent, @"Created consurrent serial queue from serial.");
}


- (void)test_currentIsMain {
    XCTAssertEqualObjects([OCAQueue main], [OCAQueue current], @"Tests should run on Main, so the +current method failed.");
}


- (void)test_current {
    [[OCAQueue background] performBlockAndWait:^{
        XCTAssertEqualObjects([OCAQueue background], [OCAQueue current], @"Running on background, current must be background.");
        
        __block BOOL passed = NO;
        [[OCAQueue background] performBlockAndWait:^{
            passed = YES;
        }];
        XCTAssertTrue(passed, @"Waiting for current should not result in deadlock");
    }];
}


- (void)test_main_sync {
    OCAQueue *queue = [[OCAQueue alloc] initWithName:@"Testing" concurrent:YES targetQueue:[OCAQueue main]];
    __block BOOL passed = NO;
    [queue performBlockAndWait:^{
        [[OCAQueue main] performBlockAndWait:^{
            passed = YES;
        }];
    }];
    XCTAssertTrue(passed, @"Waiting for Main queue while running on it should work.");
}


- (void)test_main_barrierSync {
    OCAQueue *queue = [[OCAQueue alloc] initWithName:@"Testing" concurrent:YES targetQueue:[OCAQueue main]];
    __block BOOL passed = NO;
    [queue performBarrierBlockAndWait:^{
        passed = YES;
    }];
    XCTAssertTrue(passed, @"Waiting for Main queue while running on it should work.");
}


- (void)test_readerWriter {
    NSCountedSet *resource = [[NSCountedSet alloc] init];
    OCAQueue *queue = [[OCAQueue alloc] initWithName:@"test_readerWriter.queue" concurrent:YES targetQueue:[OCAQueue background]];
    OCAQueue *resourceQueue = [[OCAQueue alloc] initWithName:@"test_readerWriter.resourceQueue" concurrent:YES targetQueue:[OCAQueue background]];
    
    NSUInteger count = 1000;
    NSArray *elements = @[ @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H" ];
    [queue performMultiple:count blocks:^(NSUInteger i) {
        
        [resourceQueue performBlockAndWait:^{
            [self heavyTask];
        }];
        
        [self heavyTask];
        id element = [elements objectAtIndex:(i % elements.count)];
        
        [resourceQueue performBarrierBlock:^{
            [resource addObject:element];
        }];
    }];
    
    [queue performBarrierBlockAndWait:^{
        [resourceQueue performBarrierBlockAndWait:^{
            [self.semaphore signal];
        }];
    }];
    BOOL signaled = [self.semaphore waitFor:10];
    XCTAssertTrue(signaled, @"Didn't pass the test.");
    
    NSUInteger finalCount = 0;
    for (id object in resource) {
        finalCount += [resource countForObject:object];
    }
    
    XCTAssertEqualObjects([NSSet setWithArray:elements], [NSSet setWithSet:resource], @"Two sets have the same elements");
    XCTAssertEqual(count, finalCount, @"Resource should contain all objects.");
}





@end


