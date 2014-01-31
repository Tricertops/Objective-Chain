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



- (void)test_validateClass_nilAlwaysPasses {
    id object = nil;
    XCTAssertTrue([OCAObject validateObject:&object ofClass:[NSMetadataQueryAttributeValueTuple class]], @"Nil must pass any class validation.");
    XCTAssertTrue([OCAObject validateObject:&object ofClass:nil], @"Nil must pass any class validation.");
    object = @"test";
    XCTAssertTrue([OCAObject validateObject:&object ofClass:[NSString class]]);
    XCTAssertTrue([OCAObject validateObject:&object ofClass:nil], @"Anything must pass for Nil class validation.");
}


- (void)test_findingCommonClass {
    NSArray *classes = @[ NSString.class, NSMutableString.class, NSString.class ];
    XCTAssertEqualObjects([OCAObject valueClassForClasses:classes], NSString.class, @"Should be highest of all concrete classes.");
}


- (void)test_deallocation {
    __block BOOL passed = NO;
    NSBlockOperation *something = [[NSBlockOperation alloc] init];
    
    [something.decomposer addOwnedObject:self cleanup:^(__unsafe_unretained NSBlockOperation *owner){
        [owner.decomposer removeOwnedObject:self]; // This line should not crash.
        
        passed = YES;
    }];
    something = nil; // Should dealloc.
    
    XCTAssertTrue(passed, @"Block associated with decomposer should be invoked when owner is deallocated.");
}





@end


