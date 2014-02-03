//
//  OCAFoundationTransformersTest.m
//  Objective-Chain
//
//  Created by Martin Kiss on 5.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAFoundation.h"
#import "OCATransformer.h"
#import "OCASubscriber.h"
#import "OCACommand.h"
#import "OCADecomposer.h"
#import "OCABridge.h"



@interface OCAFoundationTransformersTest : XCTestCase

@end



@interface OCATestObject : NSObject @end
@implementation OCATestObject @end





@implementation OCAFoundationTransformersTest




#pragma mark Notifier


- (void)test_notifications {
    NSString *notificationName = @"notificationName";
    NSObject *object = [[OCATestObject alloc] init];
    [object.decomposer addOwnedObject:self cleanup:nil];
    
    OCANotificator *notificator = [[OCANotificator alloc] initWithCenter:nil name:notificationName sender:object];
    
    __block BOOL passed = NO;
    __block BOOL finished = NO;
    [notificator subscribeForClass:[NSNotification class]
                           handler:^(NSNotification *notification) {
                               passed = [notification.name isEqualToString:notificationName];
                           }
                            finish:^(NSError *error) {
                                finished = YES;
                            }];
    [notificator.decomposer addOwnedObject:self cleanup:nil];
    notificator = nil; // Releasing ownership of Notificator, but it should live until Object is deallocated.
    
    OCACommand *command = [[OCACommand alloc] init];
    [command connectTo:[OCANotificator postNotification:notificationName sender:object]];
    [command sendValue:nil];
    
    XCTAssertTrue(passed, @"Command must invoke notification, notification must invoke block.");
}


- (void)test_sharingNotificators {
    OCANotificator *first = [OCANotificator notify:NSCurrentLocaleDidChangeNotification];
    [first connectTo:[OCABridge bridgeForClass:nil]]; // This works only after the instance is connected at least once.
    OCANotificator *second = [OCANotificator notify:NSCurrentLocaleDidChangeNotification];
    XCTAssertTrue(first == second);
}





#pragma mark NSArray


- (void)test_branchArray {
    OCATransformer *t = [OCATransformer branchArray:@[
                                                      [OCATransformer access:OCAKeyPath(NSString, uppercaseString, NSString)],
                                                      [OCATransformer access:OCAKeyPath(NSString, lowercaseString, NSString)],
                                                      [OCATransformer access:OCAKeyPath(NSString, capitalizedString, NSString)],
                                                      ]];
    NSArray *expected = @[ @"HELLO", @"hello", @"Hello" ];
    XCTAssertEqualObjects([t transformedValue:@"heLLo"], expected);
}


- (void)test_wrapInArray {
    XCTAssertEqualObjects([@"A" transform:[OCATransformer wrapInArray]], @[@"A"]);
    XCTAssertNil([[OCATransformer wrapInArray] transformedValue:nil]);
}


- (void)test_objectAtIndexes {
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:1];
    NSArray *array = @[ @"A", @"B", @"C" ];
    XCTAssertEqualObjects([array transform:[OCATransformer objectsAtIndexes:indexes]], @[ @"B" ]);
}


- (void)test_subarraying {
    NSArray *array =  [@"A-B-C-D-E" componentsSeparatedByString:@"-"];
    
    XCTAssertEqualObjects([array transform:[OCATransformer subarrayToIndex:2]], [@"A-B" componentsSeparatedByString:@"-"]);
    XCTAssertEqualObjects([array transform:[OCATransformer subarrayToIndex:8]], array);
    XCTAssertEqualObjects([array transform:[OCATransformer subarrayToIndex:-1]], [@"A-B-C-D" componentsSeparatedByString:@"-"]);
    XCTAssertEqualObjects([array transform:[OCATransformer subarrayToIndex:-6]], @[]);
    
    XCTAssertEqualObjects([array transform:[OCATransformer subarrayFromIndex:2]], [@"C-D-E" componentsSeparatedByString:@"-"]);
    XCTAssertEqualObjects([array transform:[OCATransformer subarrayFromIndex:8]], @[]);
    XCTAssertEqualObjects([array transform:[OCATransformer subarrayFromIndex:-1]], @[@"E"]);
    XCTAssertEqualObjects([array transform:[OCATransformer subarrayFromIndex:-6]], array);
    
    XCTAssertEqualObjects([array transform:[OCATransformer subarrayWithRange:NSMakeRange(1, 3)]], [@"B-C-D" componentsSeparatedByString:@"-"]);
    XCTAssertEqualObjects([array transform:[OCATransformer subarrayWithRange:NSMakeRange(3, 8)]], [@"D-E" componentsSeparatedByString:@"-"]);
    XCTAssertEqualObjects([array transform:[OCATransformer subarrayWithRange:NSMakeRange(6, 2)]], @[]);
}


- (void)test_arrayTransformation {
    NSArray *array = @[  @"de", @"ca", @"au", @"be" ];
    
    NSPredicate *endsWithE = [NSPredicate predicateWithFormat:@"self ENDSWITH[c] 'e'"];
    OCATransformer *uppercase = [OCATransformer access:OCAKeyPath(NSString, uppercaseString, NSString)];
    NSSortDescriptor *alphabet = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    
    OCATransformer *t = [OCATransformer sequence:@[
                                                   [OCATransformer filterArray:endsWithE],
                                                   [OCATransformer transformArray:uppercase],
                                                   [OCATransformer sortArray:@[ alphabet ]],
                                                   ]];
    NSArray *expected = @[  @"BE", @"DE" ];
    XCTAssertEqualObjects([array transform:t], expected);
}


- (void)test_flattenArray {
    NSArray *array3D = @[@[@[ @"A", @"B" ], @[ @"C", @"D" ]], @[@[ @"E", @"F" ], @[ @"G", @"H" ]]];
    NSArray *array2D = @[@[ @"A", @"B" ], @[ @"C", @"D" ], @[ @"E", @"F" ], @[ @"G", @"H" ]];
    NSArray *array1D = @[ @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H" ];
    XCTAssertEqualObjects([array3D transform:[OCATransformer flattenArrayRecursively:NO]], array2D);
    XCTAssertEqualObjects([array3D transform:[OCATransformer flattenArrayRecursively:YES]], array1D);
}


- (void)test_randomizeArray {
    NSArray *array = @[ @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H" ];
    XCTAssertNotEqualObjects([array transform:[OCATransformer randomizeArray]], array, @"Array must not be the same after randomization.");
}


- (void)test_mutateArray {
    NSArray *array = @[ @"D", @"A", @"C", @"A", @"B" ];
    OCATransformer *t = [OCATransformer mutateArray:^(NSMutableArray *array) {
        [array removeObjectIdenticalTo:@"A"];
        [array sortUsingSelector:@selector(compare:)];
    }];
    NSArray *expected = @[ @"B", @"C", @"D" ];
    XCTAssertEqualObjects([array transform:t], expected);
}


- (void)test_objectAtIndex {
    NSArray *array = @[ @"A", @"B", @"C" ];
    XCTAssertEqualObjects([array transform:[OCATransformer objectAtIndex:1]], @"B");
    XCTAssertEqualObjects([array transform:[OCATransformer objectAtIndex:-1]], @"C");
    XCTAssertNil([array transform:[OCATransformer objectAtIndex:5]]);
}


- (void)test_joinWithString {
    NSArray *array = @[ @"A", @"B", @"C", @"D" ];
    XCTAssertEqualObjects([array transform:[OCATransformer joinWithString:@", "]], @"A, B, C, D");
    XCTAssertEqualObjects([array transform:[OCATransformer joinWithString:@", " last:@" & "]], @"A, B, C & D");
}





@end


