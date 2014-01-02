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
                                                  transform:^NSURL *(NSString *input) {
                                                      return [NSURL URLWithString:input];
                                                  } reverse:^NSString *(NSURL *input) {
                                                      return input.absoluteString;
                                                  }];
    XCTAssertEqualObjects([transformer.class valueClass], [NSString class], @"Created transformer declares wrong input class.");
    XCTAssertEqualObjects([transformer.class transformedValueClass], [NSURL class], @"Created transformer declares wrong output class.");
    XCTAssertTrue([transformer.class allowsReverseTransformation], @"Created transformer declares wrong reversibility.");
}


- (void)test_equalClassesAfterBeingCreatedWithTheSameParameters {
    OCATransformer *uppercase = [[OCATransformer fromClass:[NSString class] toClass:[NSString class]
                                                 asymetric:^NSString *(NSString *input) {
                                                     return [input uppercaseString];
                                                 }] describe:@"uppercase"];
    OCATransformer *lowercase = [[OCATransformer fromClass:[NSString class] toClass:[NSString class]
                                                 asymetric:^NSString *(NSString *input) {
                                                     return [input lowercaseString];
                                                 }] describe:@"lowercase"];
    XCTAssertEqualObjects(uppercase.class, lowercase.class, @"Transformer classes with the same configuration differ.");
    XCTAssertNotEqualObjects(uppercase, lowercase, @"Method wrongly returned the same instance.");
}


- (void)test_transformationUsingBlocks {
    OCATransformer *uppercase = [[OCATransformer fromClass:[NSString class] toClass:[NSString class]
                                                 transform:^NSString *(NSString *input) {
                                                     return [input uppercaseString];
                                                 } reverse:^NSString *(NSString *input) {
                                                     return [input lowercaseString];
                                                 }] describe:@"uppercase" reverse:@"lowercase"];
    NSString *input = @"Hello World!";
    NSString *output = [uppercase transformedValue:input];
    NSString *reversedOutput = [uppercase reverseTransformedValue:output];
    XCTAssertEqualObjects(@"HELLO WORLD!", output, @"Transformer failed to transform value.");
    XCTAssertEqualObjects(@"hello world!", reversedOutput, @"Transformer failed to reverse transform value.");
}


- (void)test_classValidation {
    OCATransformer *t = [OCATransformer fromClass:[NSNumber class] toClass:[NSString class]
                                        transform:^NSString *(NSNumber *input) {
                                            XCTFail(@"If we pass wrong input class, this block should never be inkoved.");
                                            return input.description;
                                        } reverse:^NSNumber *(NSString *input) {
                                            XCTFail(@"If we pass wrong input class, this block should never be inkoved.");
                                            return @(input.doubleValue);
                                        }];
    XCTAssertNil([t transformedValue:@"test"], @"Object of wrong class passed transformation.");
    XCTAssertNil([t reverseTransformedValue:@42], @"Object of wrong class passed reverse transformation.");
}


- (void)test_reversibility_irreversibleTransformer {
    OCATransformer *irreversible = [[OCATransformer fromClass:[NSString class] toClass:[NSString class]
                                                    asymetric:^NSString *(NSString *input){
                                                        return [input stringByAppendingString:@"ing"];
                                                    }] describe:@"append “ing”"];
    XCTAssertFalse([irreversible.class allowsReverseTransformation], @"That constructor should return irreversible transformer.");
    
    NSString *test = @"test";
    
    NSString *transformed = [irreversible transformedValue:test];
    NSString *reverseTransformed = [irreversible reverseTransformedValue:test];
    NSString *transformedViaReversed = [irreversible.reversed transformedValue:test];
    NSString *reverseTransformedViaReversed = [irreversible.reversed reverseTransformedValue:test];
    
    XCTAssertEqualObjects(@"testing", transformed, @"Not even a simple example works?!");
    XCTAssertNil(reverseTransformed, @"Reverse transformation of irreversible transformer returns nil.");
    XCTAssertNil(transformedViaReversed, @"Transformation via reverse transformer of irreversible transformer returns nil.");
    XCTAssertEqualObjects(@"testing", reverseTransformedViaReversed, @"Double reverse should work like original.");
}





#pragma mark Predefined


- (void)test_predefinedPass_mustReturnWhatItReceives {
    OCATransformer *t = [OCATransformer pass];
    NSString *s = @"Hello!";
    XCTAssertTrue([t transformedValue:s] == s, @"Object should pass through without modifications");
}


- (void)test_predefinedSequence_gatherConfigurationBasedOnSubTransformers {
    OCATransformer *toWords = [[OCATransformer fromClass:[NSString class] toClass:[NSArray class]
                                               asymetric:^NSArray *(NSString *input) {
                                                   return [input componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                               }] describe:@"split words"];
    
    OCATransformer *countCollection = [[OCATransformer fromClass:nil toClass:[NSNumber class]
                                                       asymetric:^NSNumber *(id input) {
                                                           if ([input respondsToSelector:@selector(count)]) return @([input count]);
                                                           else return @0;
                                                       }] describe:@"count"];
    
    OCATransformer *countWords = [OCATransformer sequence:@[ toWords, countCollection ]];
    
    XCTAssertEqualObjects([countWords.class valueClass], [NSString class], @"Sequence has mismatched input class.");
    XCTAssertEqualObjects([countWords.class transformedValueClass], [NSNumber class], @"Sequence has mismatched output class.");
    XCTAssertTrue([countWords.class allowsReverseTransformation], @"Sequences are always reversible.");
    
    XCTAssertEqualObjects([countWords transformedValue:@"One two three"], @3, @"Returned unexpected value.");
}


- (void)test_predefinedSequence_reversingWorks {
    OCATransformer *appendExclamation = [[OCATransformer fromClass:[NSString class] toClass:[NSString class]
                                                          symetric:^NSString *(NSString *input) {
                                                              return [input stringByAppendingString:@"!"];
                                                          }] describe:@"append “!”"];
    
    OCATransformer *toWords = [[OCATransformer fromClass:[NSString class] toClass:[NSArray class]
                                               transform:^NSArray *(NSString *input) {
                                                   NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                                                   return [input componentsSeparatedByCharactersInSet:whitespace];
                                               } reverse:^NSString *(NSArray *input) {
                                                   return [input componentsJoinedByString:@" "];
                                               }] describe:@"split words" reverse:@"join words"];
    
    OCATransformer *reverseArray = [[OCATransformer fromClass:[NSArray class] toClass:[NSArray class]
                                                     symetric:^NSArray *(NSArray *input) {
                                                         return input.reverseObjectEnumerator.allObjects;
                                                     }] describe:@"reverse order"];
    
    OCATransformer *t = [OCATransformer sequence:@[ appendExclamation, toWords, reverseArray, [toWords reversed] ]];
    
    XCTAssertEqualObjects([t transformedValue:@"One two three four"], @"four! three two One");
    XCTAssertEqualObjects([t reverseTransformedValue:@"One two three four"], @"four three two One!");
}





@end




