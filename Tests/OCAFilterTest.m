//
//  OCAFilterTest.m
//  Objective-Chain
//
//  Created by Martin Kiss on 2.2.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAFilter.h"
#import "OCACommand.h"
#import "OCASubscriber.h"
#import "OCAPredicate.h"





@interface OCAFilterTest : XCTestCase


@property (nonatomic, readwrite, strong) OCACommand *command;
@property (nonatomic, readwrite, strong) OCASubscriber *subscriber;
@property (nonatomic, readwrite, strong) NSMutableArray *received;


@end










@implementation OCAFilterTest




- (void)setUp {
    [super setUp];
    
    self.command = [OCACommand commandForClass:[NSString class]];
    NSMutableArray *received = [[NSMutableArray alloc] init];
    self.received = received;
    self.subscriber = [OCASubscriber subscribeForClass:[NSString class] handler:^(NSString *value) {
        [received addObject:value];
    }];
}


- (void)test_simplePredicate {
    [[self.command
      filterValues:[OCAPredicate beginsWith:@"A"]]
     connectTo:self.subscriber];
    
    [self.command sendValues:@[ @"Hello", @"Aloha", @"Hi", @"Ahoy" ]];
    
    NSArray *expected = @[ @"Aloha", @"Ahoy" ];
    XCTAssertEqualObjects(self.received, expected);
}


- (void)test_skipFirst {
    [[self.command
      skipFirst:2]
     connectTo:self.subscriber];
    
    [self.command sendValues:@[ @"Hello", @"Aloha", @"Hi", @"Ahoy" ]];
    
    NSArray *expected = @[ @"Hi", @"Ahoy" ];
    XCTAssertEqualObjects(self.received, expected);
}


- (void)test_skipEqual {
    [[self.command
      skipEqual]
     connectTo:self.subscriber];
    
    [self.command sendValues:@[ @"Hello", @"Hello", @"Hi", @"Hello", @"Hi", @"Hi" ]];
    
    NSArray *expected = @[ @"Hello", @"Hi", @"Hello", @"Hi" ];
    XCTAssertEqualObjects(self.received, expected);
}




@end


