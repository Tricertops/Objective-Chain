//
//  OCAAccessorTest.m
//  Objective-Chain
//
//  Created by Martin Kiss on 3.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAStructureAccessor.h"
#import "OCAKeyPathAccessor.h"
#import "OCATransformer.h"
#import "OCAMath.h"



typedef struct {
    NSRange title;
    NSRange URL;
} OCATestLink;





@interface OCAAccessorTest : XCTestCase


@property (nonatomic, readwrite, assign) OCATestLink link;


@end





@implementation OCAAccessorTest





- (void)test_boxing_numeric {
    NSNumber *numeric = OCABox(5);
    XCTAssertTrue([numeric isKindOfClass:[NSNumber class]], @"Primitive numeric type must box into NSNumer.");
    NSUInteger integer = OCAUnbox(numeric, NSUInteger, 0);
    XCTAssertTrue(integer == 5);
    
    NSRange range = OCAUnbox(numeric, NSRange, NSMakeRange(NSNotFound, NSNotFound));
    XCTAssertTrue(range.location == NSNotFound, @"Mismatched type must use replacement.");
}


- (void)test_boxing_structure {
    NSValue *structure = OCABox(NSMakeRange(4, 39));
    XCTAssertFalse([structure isKindOfClass:[NSNumber class]], @"Non-numeric primitive type must NOT box into NSNumer.");
    NSRange range = OCAUnbox(structure, NSRange, NSMakeRange(NSNotFound, NSNotFound));
    XCTAssertTrue(range.location == 4);
    
    NSUInteger integer = OCAUnbox(structure, NSUInteger, 42);
    XCTAssertTrue(integer == 42);
}


- (void)test_memberAccess_getNumeric {
    OCAStructureAccessor *accessRangeLocation = OCAStruct(NSRange, location);
    NSValue *range = [NSValue valueWithRange:NSMakeRange(2, 5)];
    XCTAssertEqualObjects([accessRangeLocation memberFromStructure:range], @2, @"Failed to get numeric structure member.");
}


- (void)test_memberAccess_getNestedNumeric {
    OCATestLink link;
    link.title = NSMakeRange(0, 25);
    link.URL = NSMakeRange(25, 180);
    self.link = link;
    
    OCAStructureAccessor *accessLinkTitleLength = OCAStruct(OCATestLink, title.length);
    id value = [self valueForKey:@"link"];
    XCTAssertEqualObjects([accessLinkTitleLength memberFromStructure:value], @25, @"Failed to get nested numeric structure member.");
}


- (void)test_memberAccess_setNumeric {
    OCAStructureAccessor *accessRangeLength = OCAStruct(NSRange, length);
    NSValue *rangeValue = [accessRangeLength setMember:@4 toStructure:[NSValue valueWithRange:NSMakeRange(0, 0)]];
    NSRange range = [rangeValue rangeValue];
    XCTAssertTrue(range.length == 4, @"Failed to set numeric structure member");
}


- (void)test_memberAccess_setValue {
    OCATestLink link;
    self.link = link;
    
    OCAStructureAccessor *accessLinkURLLocation = OCAStruct(OCATestLink, URL);
    NSValue *modifiedLinkValue = [accessLinkURLLocation setMember:[NSValue valueWithRange:NSMakeRange(1, 2)]
                                                      toStructure:[self valueForKey:@"link"]];
    [self setValue:modifiedLinkValue forKey:@"link"];
    XCTAssertTrue(self.link.URL.location == 1, @"Failed to set sub-struc member.");
}


- (void)test_keyPath_creation {
    OCAKeyPathAccessor *kpa = OCAKeyPath(NSObject, description, NSString);
    
    XCTAssertEqualObjects(kpa.objectClass, [NSObject class]);
    XCTAssertEqualObjects(kpa.keyPath, @"description");
    XCTAssertEqualObjects(kpa.valueClass, [NSString class]);
    
    XCTAssertEqualObjects([kpa accessObject:@"ABC"], @"ABC");
}


- (void)test_keyPath_creatingPrimitive {
    OCAKeyPathAccessor *kpa = OCAKeyPath(NSString, length, NSUInteger);
    
    XCTAssertEqualObjects(kpa.objectClass, [NSString class]);
    XCTAssertEqualObjects(kpa.keyPath, @"length");
    XCTAssertEqualObjects(kpa.valueClass, [NSNumber class]);
    
    NSNumber *length = [kpa accessObject:@"12345678"];
    XCTAssertEqualObjects(length, @8);
}


- (void)test_keyPathStruct {
    OCATestLink link;
    link.title.length = 5;
    self.link = link;
    OCAKeyPathAccessor *kpa = OCAKeyPathStruct(OCAAccessorTest, link, title.length);
    
    XCTAssertEqualObjects(kpa.objectClass, [OCAAccessorTest class]);
    XCTAssertEqualObjects(kpa.keyPath, @"link");
    XCTAssertEqualObjects(kpa.valueClass, [NSNumber class]);
    
    XCTAssertEqualObjects([kpa accessObject:self], @5);
    
    [kpa modifyObject:self withValue:@10];
    XCTAssertTrue(self.link.title.length == 10);
    XCTAssertEqualObjects([kpa accessObject:self], @10);
}


- (void)test_modifyTransform {
    OCATestLink link;
    link.URL.location = 5;
    self.link = link;
    
    OCATransformer *t = [OCATransformer modify:OCAKeyPathStruct(OCAAccessorTest, link, URL.location)
                                   transformer:[OCAMath multiplyBy:5]];
    
    OCAAccessorTest *transformed = [t transformedValue:self];
    XCTAssertTrue(transformed == self, @"It should return identical object.");
    XCTAssertTrue(transformed.link.URL.location == 25);
    
    OCAAccessorTest *reverseTransformed = [t reverseTransformedValue:self];
    XCTAssertTrue(reverseTransformed == self, @"It should return identical object.");
    XCTAssertTrue(reverseTransformed.link.URL.location == 5);
    
}








@end


