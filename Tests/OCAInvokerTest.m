//
//  OCAInvokerTest.m
//  Objective-Chain
//
//  Created by Martin Kiss on 3.2.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAInvoker.h"
#import "OCACommand.h"
#import "OCAInvocationCatcher.h"





@interface OCAInvokerTest : XCTestCase


@property (atomic, readwrite, strong) NSString *value;


@end










@implementation OCAInvokerTest





- (void)setUp {
    [super setUp];
    
    self.value = nil;
}


- (void)test_simple {
    OCACommand *command = [OCACommand commandForClass:nil];
    [command invoke:OCAInvocation(self, setValue:@"ABC")];
    [command sendValue:nil];
    XCTAssertEqualObjects(self.value, @"ABC");
}


- (void)test_placeholders {
    OCACommand *command = [OCACommand commandForClass:[NSArray class]];
    
    @autoreleasepool {
        //! Autorelease pool causes the placeholders to be released, so they must be retained by the Invoker.
        [command invoke:OCAInvocation( OCAPH(OCAInvokerTest), setValue: OCAPH(NSString) )];
    }
    
    [command sendValue:@[ self, @"ABC" ]];
    XCTAssertEqualObjects(self.value, @"ABC");
}


- (void)test_nilTarget {
    id coolObject = nil;
    XCTAssertNoThrow(OCAInvocation(coolObject, test_nilTarget), "Macro should return nil when the target is nil.");
}





@end


