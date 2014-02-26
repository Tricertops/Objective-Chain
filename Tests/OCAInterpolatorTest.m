//
//  OCAInterpolatorTest.m
//  Objective-Chain
//
//  Created by Juraj Homola on 26.2.2014.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAInterpolator.h"
#import "OCAQueue.h"
#import "OCAContext.h"
#import "OCASemaphore.h"

@interface OCAInterpolatorTest : XCTestCase

@end


@implementation OCAInterpolatorTest


- (void)test_correctOrder {
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    OCASemaphore *semaphore = [[OCASemaphore alloc] initWithValue:0];
    [[OCAQueue background] performBlockAndWait:^{
        
        [[OCAInterpolator interpolatorWithDuration:1 frequency:10] subscribeForClass:[NSNumber class] handler:^(NSNumber *value) {
            [array addObject:value];
        } finish:^(NSError *error) {
            [semaphore signal];
        }];
    }];
    
    BOOL signaled = [semaphore waitFor:2];
    XCTAssertTrue(signaled);
    NSArray *sortedArray = [array sortedArrayUsingSelector:@selector(compare:)];
    XCTAssertTrue(array.count == 11);
    XCTAssertEqualObjects(sortedArray, array);
}


- (void)test_durationZero {
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    OCASemaphore *semaphore = [[OCASemaphore alloc] initWithValue:0];
    [[OCAQueue background] performBlockAndWait:^{
        
        [[OCAInterpolator interpolatorWithDuration:0 frequency:100] subscribeForClass:[NSNumber class] handler:^(NSNumber *value) {
            [array addObject:value];
        } finish:^(NSError *error) {
            [semaphore signal];
        }];
    }];
    
    BOOL signaled = [semaphore waitFor:3];
    XCTAssertTrue(signaled);
    XCTAssertTrue(array.count == 1);
    
    NSArray *expected = @[ @1 ];
    XCTAssertEqualObjects(array, expected);
}


- (void)test_frequencyZero {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    OCASemaphore *semaphore = [[OCASemaphore alloc] initWithValue:0];
    [[OCAQueue background] performBlockAndWait:^{
        
        [[OCAInterpolator interpolatorWithDuration:2 frequency:0] subscribeForClass:[NSNumber class] handler:^(NSNumber *value) {
            [array addObject:value];
        } finish:^(NSError *error) {
            [semaphore signal];
        }];
    }];
    
    BOOL signaled = [semaphore waitFor:3];
    XCTAssertTrue(signaled);
    XCTAssertTrue(array.count == 2);
    
    NSArray *expected = @[ @0, @1 ];
    XCTAssertEqualObjects(array, expected);
}


- (void)test_correctOrderCustom {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    OCASemaphore *semaphore = [[OCASemaphore alloc] initWithValue:0];
    [[OCAQueue background] performBlockAndWait:^{
        
        [[OCAInterpolator interpolatorWithDuration:1 frequency:3 fromValue:3.2 toValue:-4.5]
         subscribeForClass:[NSNumber class]
         handler:^(NSNumber *value) {
             [array addObject:value];
         } finish:^(NSError *error) {
             [semaphore signal];
         }];
    }];
    
    BOOL signaled = [semaphore waitFor:2];
    XCTAssertTrue(signaled);
    NSArray *sortedArray = [array sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO] ]];
    XCTAssertTrue(array.count == 4);
    XCTAssertEqualObjects(sortedArray, array);
}


@end
