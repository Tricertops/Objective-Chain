//
//  OCAPropertyTest.m
//  Objective-Chain
//
//  Created by Martin Kiss on 9.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAPropertyBridge.h"
#import "OCACommand.h"
#import "OCASubscriber.h"
#import "OCAHub.h"
#import "OCAFoundation.h"
#import "OCAMulticast.h"



@interface OCAPropertyTest : XCTestCase


@property (atomic, readwrite, copy) NSString *firstName;
@property (atomic, readwrite, copy) NSString *lastName;
@property (atomic, readonly, copy) NSString *fullName;

@property (atomic, readwrite, copy) NSString *jobTitle;
@property (atomic, readwrite, copy) NSString *occupation;

@property (atomic, readwrite, assign) NSUInteger birthYear;
@property (atomic, readwrite, assign) NSUInteger age;


@end





@implementation OCAPropertyTest





- (void)setUp {
    self.firstName = @"Martin";
    self.lastName = @"Kiss";
    self->_fullName = nil;
    self.jobTitle = @"Developer";
    self.occupation = nil;
    self.birthYear = 1992;
    self.age = 0;
}




- (void)test_consumingObjectValues {
    OCACommand *command = [OCACommand commandForClass:[NSString class]];
    [command connectTo:OCAProperty(self, occupation, NSString)];
    [command sendValue:@"Dude"];
    XCTAssertEqual(self.occupation, @"Dude");
}


- (void)test_consumingNumericValues {
    OCACommand *command = [OCACommand commandForClass:[NSNumber class]];
    [command connectTo:OCAProperty(self, age, NSUInteger)];
    [command sendValue:@21];
    XCTAssertTrue(self.age == 21);
}


- (void)test_producingStringValues {
    NSMutableArray *received = [[NSMutableArray alloc] init];
    [OCAProperty(self, jobTitle, NSString) connectTo:[OCASubscriber subscribeClass:[NSString class] handler:^(NSString *jobTitle) {
        [received addObject:jobTitle ?: @""];
    }]];
    self.jobTitle = @"Dude";
    self.jobTitle = @"Dude";
    self.jobTitle = nil;
    self.jobTitle = @"Developer";
    NSArray *expected = @[ @"Developer", @"Dude", @"", @"Developer" ];
    XCTAssertEqualObjects(received, expected);
}


- (void)test_twoWayBinding {
    [OCAProperty(self, jobTitle, NSString) connectTo:OCAProperty(self, occupation, NSString)];
    [OCAProperty(self, occupation, NSString) connectTo:OCAProperty(self, jobTitle, NSString)];
    
    XCTAssertEqual(self.jobTitle, self.occupation, @"Properties must be equal.");
    
    self.jobTitle = @"Dude";
    XCTAssertEqual(self.occupation, @"Dude", @"Properties must be equal.");
    
    self.occupation = @"Dev";
    XCTAssertEqual(self.jobTitle, @"Dev", @"Properties must be equal.");
}


- (void)test_combineTwoIntoOne {
    OCAProducer *combined = [OCAHub combine:@[
                                              OCAProperty(self, firstName, NSString),
                                              OCAProperty(self, lastName, NSString),
                                              ]];
    //TODO: Hub not sending initial.
    NSMutableArray *received = [[NSMutableArray alloc] init];
    OCAMulticast *consumer = [OCAMulticast multicast:@[
                                                       OCAProperty(self, fullName, NSString),
                                                       [OCASubscriber subscribeClass:[NSString class] handler:
                                                        ^(NSString *value) {
                                                            [received addObject:value ?: @""];
                                                        }],
                                                       ]];
    [combined connectWithTransform:[OCAFoundation joinWithString:@" "] to:consumer];
    
    self.lastName = @"Me";
    
    NSArray *expected = @[ @"Martin Kiss", @"Martin Me" ];
    XCTAssertEqualObjects(received, expected);
}





@end


