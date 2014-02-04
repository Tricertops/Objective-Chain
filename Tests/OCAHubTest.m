//
//  OCAHubTest.m
//  Objective-Chain
//
//  Created by Martin Kiss on 1.2.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAHub.h"
#import "OCACommand.h"
#import "OCASubscriber.h"
#import "OCAVariadic.h"





@interface OCAHubTest : XCTestCase

@property (nonatomic, readwrite, strong) OCACommand *commandA;
@property (nonatomic, readwrite, strong) OCACommand *commandB;
@property (nonatomic, readwrite, strong) OCACommand *commandC;
@property (nonatomic, readwrite, strong) NSArray *commands;

@end





@implementation OCAHubTest





- (void)setUp {
    [super setUp];
    
    self.commandA = [OCACommand commandForClass:[NSString class]];
    self.commandB = [OCACommand commandForClass:[NSString class]];
    self.commandC = [OCACommand commandForClass:[NSString class]];
    self.commands = @[ self.commandA, self.commandB, self.commandC ];
}


- (void)test_merge {
    OCAHub *hubMerge = [OCAHub merge:OCAVariadic(self.commands)];
    XCTAssertEqualObjects(hubMerge.valueClass, [NSString class], @"Merging hub should know class.");
    
    NSMutableArray *received = [NSMutableArray array];
    [hubMerge subscribeForClass:[NSString class] handler:^(id value) {
        [received addObject:value];
    }];
    
    [self.commandA sendValue:@"A"];
    [self.commandB sendValue:@"B"];
    [self.commandC sendValue:@"C"];
    
    NSArray *expected = @[ @"A", @"B", @"C" ];
    XCTAssertEqualObjects(received, expected);
}


- (void)test_combine {
    OCAHub *hubCombine = [OCAHub combine:OCAVariadic(self.commands)];
    XCTAssertEqualObjects(hubCombine.valueClass, [NSArray class], @"Combining hub must produce arrays.");
    
    NSMutableArray *received = [NSMutableArray array];
    [hubCombine subscribeForClass:[NSArray class] handler:^(id value) {
        [received addObject:value];
    }];
    
    [self.commandA sendValue:@"A"];
    [self.commandB sendValue:@"B"];
    [self.commandC sendValue:@"C"];
    
    NSArray *expected = @[ @[ @"A", NSNull.null, NSNull.null ],
                           @[ @"A", @"B", NSNull.null ],
                           @[ @"A", @"B", @"C" ] ];
    XCTAssertEqualObjects(received, expected);
}


- (void)test_dependency {
    OCAHub *hubDependency = [self.commandA dependOn:self.commandB, self.commandC, nil];
    XCTAssertEqualObjects(hubDependency.valueClass, [NSString class], @"Dependency hub should know class.");
    
    NSMutableArray *received = [NSMutableArray array];
    [hubDependency subscribeForClass:[NSString class] handler:^(id value) {
        [received addObject:value];
    }];
    
    [self.commandA sendValue:@"A"];
    [self.commandB sendValue:@"B"];
    [self.commandC sendValue:@"C"];
    
    NSArray *expected = @[ @"A", @"A", @"A" ];
    XCTAssertEqualObjects(received, expected);
}


//TODO: Test finishing.





@end


