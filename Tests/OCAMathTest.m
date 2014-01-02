//
//  OCAMathTest.m
//  Objective-Chain
//
//  Created by Martin Kiss on 2.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAMath.h"



@interface OCAMathTest : XCTestCase

@end





@implementation OCAMathTest





- (void)test_generic {
    OCATransformer *t = [OCAMath transform:^OCAReal(OCAReal x) {
        return (x * 4 - 5) / 3;
    } reverse:^OCAReal(OCAReal x) {
        return (x * 3 + 5) / 4;
    }];
    
    XCTAssertEqualObjects([t transformedValue:@8], @9);
    XCTAssertEqualObjects([t reverseTransformedValue:@9], @8);
}


- (void)test_function {
    OCATransformer *cosine = [OCAMath function:&cos reverse:&acos];
    XCTAssertEqualObjects([cosine transformedValue:@0], @1);
    XCTAssertEqualObjects([cosine reverseTransformedValue:@1], @0);
}


- (void)test_basicOperations {
    OCATransformer *t = [OCATransformer sequence:@[
                                                   [OCAMath add:3],
                                                   [OCAMath multiplyBy:4],
                                                   [OCAMath divideBy:2],
                                                   [OCAMath subtract:5],
                                                   ]];
    XCTAssertEqualObjects([t transformedValue:@8], @17);
    XCTAssertEqualObjects([t reverseTransformedValue:@17], @8);
}


- (void)test_advancedOperations {
    OCATransformer *t = [OCATransformer sequence:@[
                                                   [OCAMath powerBy:4],
                                                   [OCAMath rootOf:2],
                                                   [OCAMath logarithmWithBase:10],
                                                   ]];
    XCTAssertEqualObjects([t transformedValue:@10], @2);
    XCTAssertEqualObjects([t reverseTransformedValue:@2], @10);
}





@end


