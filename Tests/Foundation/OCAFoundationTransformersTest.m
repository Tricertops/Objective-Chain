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
    XCTAssertEqualObjects([[OCAFoundation wrapInArray] transformedValue:@"A"], @[@"A"]);
    XCTAssertNil([[OCAFoundation wrapInArray] transformedValue:nil]);
}



@end


