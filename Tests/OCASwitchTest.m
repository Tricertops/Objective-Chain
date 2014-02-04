//
//  OCASwitchTest.m
//  Objective-Chain
//
//  Created by Martin Kiss on 4.2.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCASwitch.h"
#import "OCACommand.h"
#import "OCASubscriber.h"
#import "OCAPredicate.h"





@interface OCASwitchTest : XCTestCase

@end





@implementation OCASwitchTest





- (void)test_ {
    __block NSNumber *result = nil;
    OCACommand *command = [OCACommand commandForClass:[NSString class]];
    [command switchIf:[OCAPredicate beginsWith:@"A"]
                 then:[OCASubscriber subscribe:
                       ^{
                           result = @YES;
                       }]
                 else:[OCASubscriber subscribe:
                       ^{
                           result = @NO;
                       }]];
    [command sendValue:@"Aloha"];
    XCTAssertTrue(result.boolValue);
    
    [command sendValue:@"Hello"];
    XCTAssertFalse(result.boolValue);
}





@end


