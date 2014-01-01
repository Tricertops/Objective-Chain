//
//  OCATransformerTest.m
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer.h"



@interface OCATransformerTest : XCTestCase

@end





@implementation OCATransformerTest



- (void)setUp {
    [super setUp];
}


- (void)tearDown {
    [super tearDown];
}





- (void)test_correctAdHocSubclassing {
    OCATransformer *transformer = [OCATransformer fromClass:[NSString class] toClass:[NSURL class]
                                                 transformation:^NSURL *(NSString *input) {
                                                     return [NSURL URLWithString:input];
                                                 } reverseTransformation:^NSString *(NSURL *input) {
                                                     return input.absoluteString;
                                                 }];
    XCTAssertEqualObjects([transformer.class valueClass], [NSString class], @"Created transformer declares wrong input class.");
    XCTAssertEqualObjects([transformer.class transformedValueClass], [NSURL class], @"Created transformer declares wrong output class.");
    XCTAssertTrue([transformer.class allowsReverseTransformation], @"Created transformer declares wrong reversibility.");
}


- (void)test_equalClassesAfterbeingCreatedWithTheSameParameters {
    OCATransformer *uppercase = [OCATransformer fromClass:[NSString class] toClass:[NSString class]
                                           transformation:^NSString *(NSString *input) {
                                               return [input uppercaseString];
                                           }];
    OCATransformer *lowercase = [OCATransformer fromClass:[NSString class] toClass:[NSString class]
                                           transformation:^NSString *(NSString *input) {
                                               return [input lowercaseString];
                                           }];
    XCTAssertEqualObjects(uppercase.class, lowercase.class, @"Transformer classes with the same configuration differ.");
    XCTAssertNotEqualObjects(uppercase, lowercase, @"Method wrongly returned the same instance.");
}


- (void)test_transformationUsingBlocks {
    OCATransformer *uppercaseTransformer = [OCATransformer fromClass:[NSString class] toClass:[NSString class]
                                           transformation:^NSString *(NSString *input) {
                                               return [input uppercaseString];
                                           } reverseTransformation:^NSString *(NSString *input) {
                                               return [input lowercaseString];
                                           }];
    NSString *input = @"Hello World!";
    NSString *output = [uppercaseTransformer transformedValue:input];
    NSString *reversedOutput = [uppercaseTransformer reverseTransformedValue:output];
    XCTAssertEqualObjects(@"HELLO WORLD!", output, @"Transformer failed to transform value.");
    XCTAssertEqualObjects(@"hello world!", reversedOutput, @"Transformer failed to reverse transform value.");
}





@end
