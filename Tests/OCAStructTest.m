//
//  OCAStructTest.m
//  Objective-Chain
//
//  Created by Martin Kiss on 3.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAStructMemberAccessor.h"



typedef struct {
    NSRange title;
    NSRange URL;
} OCATestLink;





@interface OCAStructTest : XCTestCase


@property (nonatomic, readwrite, assign) OCATestLink link;


@end





@implementation OCAStructTest





- (void)test_memberAccess_getNumeric {
    OCAStructMemberAccessor *accessRangeLocation = OCAStruct(NSRange, location);
    NSValue *point = [NSValue valueWithRange:NSMakeRange(2, 5)];
    XCTAssertEqualObjects([accessRangeLocation memberFromStructure:point], @2, @"Failed to get numeric structure member.");
}


- (void)test_memberAccess_getNestedNumeric {
    OCATestLink link;
    link.title = NSMakeRange(0, 25);
    link.URL = NSMakeRange(25, 180);
    self.link = link;
    
    OCAStructMemberAccessor *accessLinkTitleLength = OCAStruct(OCATestLink, title.length);
    id value = [self valueForKey:@"link"];
    XCTAssertEqualObjects([accessLinkTitleLength memberFromStructure:value], @25, @"Failed to get nested numeric structure member.");
}


- (void)test_memberAccess_setNumeric {
    OCAStructMemberAccessor *accessRangeLength = OCAStruct(NSRange, length);
    NSValue *rangeValue = [accessRangeLength setMember:@4 toStructure:[NSValue valueWithRange:NSMakeRange(0, 0)]];
    NSRange range = [rangeValue rangeValue];
    XCTAssertTrue(range.length == 4, @"Failed to set numeric structure member");
}





@end


