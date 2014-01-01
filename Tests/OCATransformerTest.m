//
//  OCATransformerTest.m
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer.h"
#import "OCATransformer+Predefined.h"



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


- (void)test_classValidation {
    OCATransformer *t = [OCATransformer fromClass:[NSNumber class] toClass:[NSString class] transformation:^NSString *(NSNumber *input) {
        XCTFail(@"If we pass wrong input class, this block should never be inkoved.");
        return input.description;
    } reverseTransformation:^NSNumber *(NSString *input) {
        XCTFail(@"If we pass wrong input class, this block should never be inkoved.");
        return @(input.doubleValue);
    }];
    XCTAssertNil([t transformedValue:@"test"], @"Object of wrong class passed transformation.");
    XCTAssertNil([t reverseTransformedValue:@42], @"Object of wrong class passed reverse transformation.");
}




- (void)test_predefinedPass_mustReturnWhatItReceives {
    OCATransformer *t = [OCATransformer pass];
    id s = @"Hello!";
    XCTAssertTrue([t transformedValue:s] == s, @"Object should pass through without modifications");
}


- (void)test_predefinedSequence_gatherConfigurationBasedOnSubTransformers {
    NSValueTransformer *toWords = [OCATransformer fromClass:[NSString class] toClass:[NSArray class]
                                             transformation:^NSArray *(NSString *input) {
                                                 return [input componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                             }];
    NSValueTransformer *countCollection = [OCATransformer fromClass:nil toClass:[NSNumber class]
                                             transformation:^NSNumber *(id input) {
                                                 if ([input respondsToSelector:@selector(count)]) return @([input count]);
                                                 else return @0;
                                             }];
    NSValueTransformer *countWords = [OCATransformer sequence:@[ toWords, countCollection ]];
    
    XCTAssertEqualObjects([countWords.class valueClass], [NSString class], @"Sequence has mismatched input class.");
    XCTAssertEqualObjects([countWords.class transformedValueClass], [NSNumber class], @"Sequence has mismatched output class.");
    XCTAssertFalse([countWords.class allowsReverseTransformation], @"Sequence wrongly declares reversibility..");
    
    XCTAssertEqualObjects([countWords transformedValue:@"One two three"], @3, @"Returned unexpected value.");
}





@end
