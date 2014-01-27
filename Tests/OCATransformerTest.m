//
//  OCATransformerTest.m
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer.h"
#import "OCAFoundation.h"
#import "OCAStructureAccessor.h"



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


- (void)test_specialization {
    OCATransformer *t = [[OCATransformer pass] specializeFromClass:[NSString class] toClass:[NSString class]];
    XCTAssertEqualObjects([t transformedValue:@"A"], @"A");
    XCTAssertNil([t transformedValue:@4], @"Should pass only strings.");
    
    OCATransformer *generalized = [t specializeFromClass:[NSNumber class] toClass:[NSObject class]];
    XCTAssertNil([generalized transformedValue:@4], @"Generalization is not possible, still returns nils.");
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
    
    OCATransformer *countWords = [OCATransformer sequence:@[ toWords, [OCATransformer countCollection] ]];
    
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


- (void)test_predefinedRepeat_transformRequiredNumerOfTimes {
    OCATransformer *appendExclamation = [[OCATransformer fromClass:[NSString class] toClass:[NSString class]
                                                         transform:^NSString *(NSString *input) {
                                                             return [input stringByAppendingString:@"!"];
                                                         } reverse:^NSString *(NSString *input) {
                                                             if ([input hasSuffix:@"!"]) return [input substringToIndex:input.length-1];
                                                             else return input;
                                                         }] describe:@"append “!”" reverse:@"remove appended “!”"];
    OCATransformer *t = [OCATransformer repeat:5 transformer:appendExclamation];
    
    XCTAssertEqualObjects([t transformedValue:@"Hello"], @"Hello!!!!!");
    XCTAssertEqualObjects([t reverseTransformedValue:@"Hello!!!"], @"Hello");
}


- (void)test_predefinedRepeat {
    OCATransformer *toWords = [[OCATransformer fromClass:[NSString class] toClass:[NSArray class]
                                               transform:^NSArray *(NSString *input) {
                                                   NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                                                   return [input componentsSeparatedByCharactersInSet:whitespace];
                                               } reverse:^NSString *(NSArray *input) {
                                                   return [input componentsJoinedByString:@" "];
                                               }] describe:@"split words" reverse:@"join words"];
    OCATransformer *t = [OCATransformer repeat:10 transformer:toWords];
    XCTAssertNil([t transformedValue:@"Hello World!"], @"Incompatible transformer should be replaced by null.");
}


- (void)test_predefinedIfThenElse {
    NSPredicate *condition = [NSPredicate predicateWithFormat:@"self BEGINSWITH 'A'"];
    OCATransformer *appendExclamation = [[OCATransformer fromClass:[NSString class] toClass:[NSString class]
                                                          symetric:^NSString *(NSString *input) {
                                                              return [input stringByAppendingString:@"!"];
                                                          }] describe:@"append “!”"];
    OCATransformer *uppercase = [[OCATransformer fromClass:[NSObject class] toClass:[NSString class]
                                                 transform:^NSString *(NSString *input) {
                                                     return [input uppercaseString];
                                                 } reverse:^NSString *(NSString *input) {
                                                     return [input lowercaseString];
                                                 }] describe:@"to uppercase" reverse:@" to lowercase"];
    
    OCATransformer *t = [OCATransformer if:condition then:appendExclamation else:uppercase];
    
    XCTAssertEqualObjects([t transformedValue:@"Au"], @"Au!", @"Didn't invoke 'then' branch.");
    XCTAssertEqualObjects([t transformedValue:@"Be"], @"BE", @"Didn't invoke 'else' branch.");
}


- (void)test_predefinedTraverseKeyPath {
    OCATransformer *t = [OCATransformer access:OCAKeyPath(NSString, length, NSUInteger)];
    XCTAssertEqualObjects([t transformedValue:@"123456"], @6);
}


- (void)test_predefinedReplace {
    OCATransformer *t = [OCATransformer replaceWith:@"A"];
    XCTAssertEqualObjects([t transformedValue:@"B"], @"A");
    XCTAssertEqualObjects([t.class transformedValueClass], [NSString class], @"Must not declare private subclasses.");
}


- (void)test_predefinedNonNull {
    OCATransformer *t = [OCATransformer replaceNil:@"A"];
    XCTAssertEqualObjects([t transformedValue:@"B"], @"B");
    XCTAssertNotNil([t transformedValue:nil]);
}


- (void)test_predefinedMap_NSDictionary {
    OCATransformer *t = [OCATransformer map:@{
                                             @"A": @1,
                                             @"B": @4,
                                             @"C": @8,
                                             }];
    XCTAssertEqualObjects([t.class valueClass], [NSString class], @"Key classes are consistent NSStrings.");
    XCTAssertEqualObjects([t.class transformedValueClass], [NSNumber class], @"Object classes are consistent NSNumbers.");
    XCTAssertEqualObjects([t transformedValue:@"C"], @8);
    XCTAssertNil([t transformedValue:@"D"]);
    XCTAssertEqualObjects([t reverseTransformedValue:@1], @"A");
    XCTAssertNil([t reverseTransformedValue:@100]);
}


- (void)test_predefinedKindOfClass {
    OCATransformer *t = [OCATransformer kindOfClass:[NSString class] or:[@"a" mutableCopy]];
    XCTAssertEqualObjects([t.class transformedValueClass], [NSString class], @"Output class should be detected.");
    XCTAssertEqualObjects([t transformedValue:@"test"], @"test");
    XCTAssertEqualObjects([t transformedValue:@42], @"a");
}


- (void)test_predefinedAccessStruct {
    OCATransformer *t = [OCATransformer access:OCAStruct(NSRange, location)];
    NSValue *rangeValue = OCABox(NSMakeRange(2, 6));
    XCTAssertEqualObjects([t transformedValue:rangeValue], @2);
    XCTAssertNil([t transformedValue:OCABox(5)], @"Must return nil for anything incompatible.");
}


- (void)test_predefinedModifyStruct {
    OCATransformer *t = [OCATransformer modify:OCAStruct(NSRange, location) value:@8];
    NSValue *rangeValue = [t transformedValue:OCABox(NSMakeRange(2, 6))];
    NSRange range = OCAUnbox(rangeValue, NSRange, NSMakeRange(NSNotFound, 0));
    
    XCTAssertTrue(range.location == 8);
    XCTAssertNil([t transformedValue:OCABox(5)], @"Must return nil for anything incompatible.");
}





@end




