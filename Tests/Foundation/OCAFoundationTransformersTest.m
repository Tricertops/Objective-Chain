//
//  OCAFoundationTransformersTest.m
//  Objective-Chain
//
//  Created by Martin Kiss on 5.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer+Foundation.h"
#import "OCATransformer+Predefined.h"



@interface OCAFoundationTransformersTest : XCTestCase

@end





@implementation OCAFoundationTransformersTest



- (void)test_branchArray {
    OCATransformer *t = [OCAFoundation branchArray:@[
                                                     [OCATransformer accessKeyPath:OCAKeypath(NSString, uppercaseString)],
                                                     [OCATransformer accessKeyPath:OCAKeypath(NSString, lowercaseString)],
                                                     [OCATransformer accessKeyPath:OCAKeypath(NSString, capitalizedString)],
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
    OCATransformer *uppercase = [OCATransformer accessKeyPath:OCAKeypath(NSString, uppercaseString)];
    NSSortDescriptor *alphabet = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    
    OCATransformer *t = [OCATransformer sequence:@[
                                                   [OCAFoundation filterArray:endsWithE],
                                                   [OCAFoundation transformArray:uppercase],
                                                   [OCAFoundation sortArray:@[ alphabet ]],
                                                   ]];
    NSArray *expected = @[  @"BE", @"DE" ];
    XCTAssertEqualObjects([array transform:t], expected);
}



@end


