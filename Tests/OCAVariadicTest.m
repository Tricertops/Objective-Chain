//
//  OCAVariadicTest.m
//  Objective-Chain
//
//  Created by Martin Kiss on 1.2.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAVariadic.h"




@interface OCAVariadicTest : XCTestCase

@end





@implementation OCAVariadicTest





- (void)test_stringFormatting {
    NSString *result = [self format:@"A %@ %@", @"B", @"C"];
    XCTAssertEqualObjects(result, @"A B C");
}


- (NSString *)format:(NSString *)format, ... NS_FORMAT_ARGUMENT(1) {
    return OCAStringFromFormat(format);
}





- (void)test_variadic_simple {
    NSArray *result = [self variadic:@"A", @"B", nil];
    NSArray *expected = @[ @"A", @"B" ];
    XCTAssertEqualObjects(result, expected);
}


- (void)test_variadic_array {
    NSArray *expected = @[ @"A", @"B" ];
    NSArray *result = [self variadic:OCAVariadic(expected)];
    XCTAssertEqualObjects(result, expected);
}


- (void)test_variadic_mixed {
    NSArray *tail = @[ @"C", @"D" ];
    NSArray *result = [self variadic:@"A", @"B", OCAVariadic(tail)];
    NSArray *expected = @[ @"A", @"B", @"C", @"D" ];
    XCTAssertEqualObjects(result, expected);
}


- (NSArray *)variadic:(NSString *)string, ... NS_REQUIRES_NIL_TERMINATION {
    return OCAArrayFromVariadicArguments(string);
}





@end


