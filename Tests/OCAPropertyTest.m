//
//  OCAPropertyTest.m
//  Objective-Chain
//
//  Created by Martin Kiss on 9.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAProperty.h"
#import "OCACommand.h"
#import "OCASubscriber.h"
#import "OCAHub.h"
#import "OCAFoundation.h"
#import "NSArray+Ordinals.h"
#import "OCABridge.h"



@interface OCAPropertyTest : XCTestCase


@property (atomic, readwrite, copy) NSString *firstName;
@property (atomic, readwrite, copy) NSString *lastName;
@property (atomic, readonly, copy) NSString *fullName;

@property (atomic, readwrite, copy) NSString *jobTitle;
@property (atomic, readwrite, copy) NSString *occupation;

@property (atomic, readwrite, assign) NSUInteger birthYear;
@property (atomic, readwrite, assign) NSUInteger age;
@property (atomic, readwrite, assign) NSRange lifespan;


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
    self.lifespan = NSMakeRange(0, 0);
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


- (void)test_consumingNils {
    OCACommand *command = [OCACommand commandForClass:[NSNumber class]];
    [command connectTo:OCAProperty(self, birthYear, NSUInteger)];
    [command sendValue:nil];
    XCTAssertTrue(self.age == 0);
}


- (void)test_producingStringValues {
    NSMutableArray *received = [[NSMutableArray alloc] init];
    [OCAProperty(self, jobTitle, NSString)
     subscribeForClass:[NSString class] handler:^(NSString *jobTitle) {
         [received addObject:jobTitle ?: @""];
     }];
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
    OCAProducer *combined = [OCAHub combine:
                             OCAProperty(self, firstName, NSString),
                             OCAProperty(self, lastName, NSString),
                             nil];
    NSMutableArray *received = [[NSMutableArray alloc] init];
    [[combined transformValues:
      [OCATransformer joinWithString:@" "],
      nil] connectToMany:
     OCAProperty(self, fullName, NSString),
     [OCASubscriber subscribeForClass:[NSString class]
                              handler:^(NSString *value) {
                                  [received addObject:value ?: @""];
                              }],
     nil];
    
    self.lastName = @"Me";
    
    NSArray *expected = @[ @"Martin Kiss", @"Martin Me" ];
    XCTAssertEqualObjects(received, expected);
}


- (void)test_bindWithTransform {
    [OCAProperty(self, birthYear, NSUInteger)
     bindTransformed:[OCAMath subtractFrom:2014]
     with:OCAProperty(self, age, NSUInteger)];
    
    XCTAssertTrue(self.age == 22);
    self.birthYear = 1991;
    XCTAssertTrue(self.age == 23);
    self.age = 50;
    XCTAssertTrue(self.birthYear == 1964);
}


- (void)test_bindWithStructure {
    [OCAProperty(self, birthYear, NSUInteger)
     bindTransformed:[OCAMath subtractFrom:2014]
     with:OCAProperty(self, age, NSUInteger)];
    
    [OCAProperty(self, birthYear, NSUInteger)
     bindWith:OCAPropertyStruct(self, lifespan, location)];
    
    [OCAProperty(self, age, NSUInteger)
     bindWith:OCAPropertyStruct(self, lifespan, length)];
    
    XCTAssertTrue(self.lifespan.location == 1992);
    XCTAssertTrue(self.lifespan.length == 22);
    
    self.lifespan = NSMakeRange(1990, 24);
    XCTAssertTrue(self.birthYear == 1990);
    XCTAssertTrue(self.age == 24);
    
    self.birthYear = 2000;
    XCTAssertTrue(self.age == 14);
    XCTAssertTrue(self.lifespan.location == 2000);
    XCTAssertTrue(self.lifespan.length == 14);
}


- (void)test_changesWithPrevious {
    __block NSString *old = nil;
    __block NSString *new = nil;
    
    OCAProperty *property = OCAProperty(self, firstName, NSString);
    OCAProducer *producer = [property producePreviousWithLatest];
    [producer
     subscribeForClass:[NSArray class]
     handler:^(NSArray *change) {
         old = [change oca_valueAtIndex:0];
         new = [change oca_valueAtIndex:1];
     }];
    
    XCTAssertNil(old);
    XCTAssertEqualObjects(new, @"Martin");
    
    self.firstName = @"Juraj";
    XCTAssertEqualObjects(old, @"Martin");
    XCTAssertEqualObjects(new, @"Juraj");
}


- (void)test_sharedInstances {
    OCAProperty *first = OCAProperty(self, lastName, NSString);
    OCAProperty *second = OCAProperty(self, lastName, NSString);
    XCTAssertTrue(first == second);
}





@end


