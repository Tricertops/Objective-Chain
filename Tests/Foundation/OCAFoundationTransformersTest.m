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
                                                     [OCATransformer accessKeyPath:OCAKeypathClass(NSString, uppercaseString)],
                                                     [OCATransformer accessKeyPath:OCAKeypathClass(NSString, lowercaseString)],
                                                     [OCATransformer accessKeyPath:OCAKeypathClass(NSString, capitalizedString)],
                                                     ]];
    NSArray *expected = @[ @"HELLO", @"hello", @"Hello" ];
    XCTAssertEqualObjects([t transformedValue:@"heLLo"], expected);
}


- (void)test_wrapInArray {
    XCTAssertEqualObjects([@"A" transform:[OCAFoundation wrapInArray]], @[@"A"]);
    XCTAssertNil([[OCAFoundation wrapInArray] transformedValue:nil]);
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



@end


