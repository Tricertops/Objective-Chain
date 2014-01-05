//
//  OCAObjectTest.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAObject.h"
#import "ObjectiveChain.h"



@interface OCAObjectTest : XCTestCase


@property (nonatomic, readwrite, strong) id lazyProperty;


@end





@implementation OCAObjectTest





- (void)setUp {
    [super setUp];
}


- (void)tearDown{
    [super tearDown];
}





#pragma mark OCALazyGetter


OCALazyGetter(id, lazyProperty) {
    return @"Not nil!";
}


- (void)test_OCALazyGetter_neverReturnNil {
    XCTAssertNotNil(self.lazyProperty, @"Didn't create lazy object on first access.");
    self.lazyProperty = nil;
    XCTAssertNotNil(self.lazyProperty, @"Didn't create lazy object after nullify.");
}





#pragma mark OCAssert


- (void)test_OCAAssert_executeAppendedCode {
#if defined(NS_BLOCK_ASSERTIONS)
    BOOL condition = NO;
    BOOL executed = NO;
    
    OCAAssert(condition, @"Condition is not met.") executed = YES;
    
    XCTAssertTrue(executed, @"Didn't execute appended code.");
#else
    XCTFail(@"Foundation assertions are enabled.");
#endif

}



- (void)test_OCAValidateClass_nilAlwaysPasses {
    id object = nil;
    XCTAssertTrue(OCAValidateClass(object, [NSMetadataQueryAttributeValueTuple class]), @"Nil must pass any class validation.");
    XCTAssertTrue(OCAValidateClass(object, Nil), @"Nil must pass any class validation.");
    object = @"test";
    XCTAssertTrue(OCAValidateClass(object, [NSString class]));
    XCTAssertTrue(OCAValidateClass(object, Nil), @"Anything must pass for Nil class validation.");
}


- (void)test_findingCommonClass {
    NSArray *classes = @[ NSString.class, NSMutableString.class, NSObject.class, NSNull.null, NSString.class ];
    XCTAssertEqualObjects([OCAObject valueClassForClasses:classes], NSString.class, @"Should be highest of all concrete classes.");
}





@end
