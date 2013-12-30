//
//  OCAObjectTest.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//
//

#import "OCAObject.h"



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





@end
