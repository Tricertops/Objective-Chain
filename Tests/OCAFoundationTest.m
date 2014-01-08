//
//  OCAFoundationTransformersTest.m
//  Objective-Chain
//
//  Created by Martin Kiss on 5.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAFoundation.h"
#import "OCATransformer+Predefined.h"
#import "OCASubscriber.h"
#import "OCACommand.h"



@interface OCAFoundationTransformersTest : XCTestCase

@end





@implementation OCAFoundationTransformersTest




#pragma mark Notifier


- (void)test_notifications {
    NSString *notificationName = @"notificationName";
    OCANotifier *notifier = [OCANotifier notify:notificationName];
    
    __block BOOL passed = NO;
    [notifier connectTo:[OCASubscriber subscribeClass:[NSNotification class] handler:
                         ^(NSNotification *notification) {
                             passed = [notification.name isEqualToString:notificationName] && notification.object == self;
                         }]];
    OCACommand *command = [OCACommand command];
    [command connectTo:[OCANotifier postNotification:notificationName sender:self]];
    
    [command sendValue:nil];
    
    XCTAssertTrue(passed, @"Command must invoke notification, notification must invoke block.");
}





#pragma mark NSArray


- (void)test_branchArray {
    OCATransformer *t = [OCAFoundation branchArray:@[
                                                     [OCATransformer access:OCAKeyPath(NSString, uppercaseString, NSString)],
                                                     [OCATransformer access:OCAKeyPath(NSString, lowercaseString, NSString)],
                                                     [OCATransformer access:OCAKeyPath(NSString, capitalizedString, NSString)],
                                                     ]];
    NSArray *expected = @[ @"HELLO", @"hello", @"Hello" ];
    XCTAssertEqualObjects([t transformedValue:@"heLLo"], expected);
}


- (void)test_wrapInArray {
    XCTAssertEqualObjects([@"A" transform:[OCAFoundation wrapInArray]], @[@"A"]);
    XCTAssertNil([[OCAFoundation wrapInArray] transformedValue:nil]);
}


- (void)test_objectAtIndexes {
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:1];
    NSArray *array = @[ @"A", @"B", @"C" ];
    XCTAssertEqualObjects([array transform:[OCAFoundation objectsAtIndexes:indexes]], @[ @"B" ]);
}


- (void)test_subarraying {
    NSArray *array =  [@"A-B-C-D-E" componentsSeparatedByString:@"-"];
    
    XCTAssertEqualObjects([array transform:[OCAFoundation subarrayToIndex:2]], [@"A-B" componentsSeparatedByString:@"-"]);
    XCTAssertEqualObjects([array transform:[OCAFoundation subarrayToIndex:8]], array);
    XCTAssertEqualObjects([array transform:[OCAFoundation subarrayToIndex:-1]], [@"A-B-C-D" componentsSeparatedByString:@"-"]);
    XCTAssertEqualObjects([array transform:[OCAFoundation subarrayToIndex:-6]], @[]);
    
    XCTAssertEqualObjects([array transform:[OCAFoundation subarrayFromIndex:2]], [@"C-D-E" componentsSeparatedByString:@"-"]);
    XCTAssertEqualObjects([array transform:[OCAFoundation subarrayFromIndex:8]], @[]);
    XCTAssertEqualObjects([array transform:[OCAFoundation subarrayFromIndex:-1]], @[@"E"]);
    XCTAssertEqualObjects([array transform:[OCAFoundation subarrayFromIndex:-6]], array);
    
    XCTAssertEqualObjects([array transform:[OCAFoundation subarrayWithRange:NSMakeRange(1, 3)]], [@"B-C-D" componentsSeparatedByString:@"-"]);
    XCTAssertEqualObjects([array transform:[OCAFoundation subarrayWithRange:NSMakeRange(3, 8)]], [@"D-E" componentsSeparatedByString:@"-"]);
    XCTAssertEqualObjects([array transform:[OCAFoundation subarrayWithRange:NSMakeRange(6, 2)]], @[]);
}


- (void)test_arrayTransformation {
    NSArray *array = @[  @"de", @"ca", @"au", @"be" ];
    
    NSPredicate *endsWithE = [NSPredicate predicateWithFormat:@"self ENDSWITH[c] 'e'"];
    OCATransformer *uppercase = [OCATransformer access:OCAKeyPath(NSString, uppercaseString, NSString)];
    NSSortDescriptor *alphabet = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    
    OCATransformer *t = [OCATransformer sequence:@[
                                                   [OCAFoundation filterArray:endsWithE],
                                                   [OCAFoundation transformArray:uppercase],
                                                   [OCAFoundation sortArray:@[ alphabet ]],
                                                   ]];
    NSArray *expected = @[  @"BE", @"DE" ];
    XCTAssertEqualObjects([array transform:t], expected);
}


- (void)test_flattenArray {
    NSArray *array3D = @[@[@[ @"A", @"B" ], @[ @"C", @"D" ]], @[@[ @"E", @"F" ], @[ @"G", @"H" ]]];
    NSArray *array2D = @[@[ @"A", @"B" ], @[ @"C", @"D" ], @[ @"E", @"F" ], @[ @"G", @"H" ]];
    NSArray *array1D = @[ @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H" ];
    XCTAssertEqualObjects([array3D transform:[OCAFoundation flattenArrayRecursively:NO]], array2D);
    XCTAssertEqualObjects([array3D transform:[OCAFoundation flattenArrayRecursively:YES]], array1D);
}


- (void)test_randomizeArray {
    NSArray *array = @[ @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H" ];
    XCTAssertNotEqualObjects([array transform:[OCAFoundation randomizeArray]], array, @"Array must not be the same after randomization.");
}


- (void)test_mutateArray {
    NSArray *array = @[ @"D", @"A", @"C", @"A", @"B" ];
    OCATransformer *t = [OCAFoundation mutateArray:^(NSMutableArray *array) {
        [array removeObjectIdenticalTo:@"A"];
        [array sortUsingSelector:@selector(compare:)];
    }];
    NSArray *expected = @[ @"B", @"C", @"D" ];
    XCTAssertEqualObjects([array transform:t], expected);
}


- (void)test_objectAtIndex {
    NSArray *array = @[ @"A", @"B", @"C" ];
    XCTAssertEqualObjects([array transform:[OCAFoundation objectAtIndex:1]], @"B");
    XCTAssertEqualObjects([array transform:[OCAFoundation objectAtIndex:-1]], @"C");
    XCTAssertNil([array transform:[OCAFoundation objectAtIndex:5]]);
}


- (void)test_joinWithString {
    NSArray *array = @[ @"A", @"B", @"C", @"D" ];
    XCTAssertEqualObjects([array transform:[OCAFoundation joinWithString:@", "]], @"A, B, C, D");
    XCTAssertEqualObjects([array transform:[OCAFoundation joinWithString:@", " last:@" & "]], @"A, B, C & D");
}





@end


