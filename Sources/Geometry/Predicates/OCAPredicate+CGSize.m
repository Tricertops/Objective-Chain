//
//  OCAPredicate+CGSize.m
//  Objective-Chain
//
//  Created by Martin Kiss on 28.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAPredicate+CGSize.h"
#import "OCAGeometry+Functions.h"










@implementation OCAPredicate (CGSize)





+ (NSPredicate *)predicateForSize:(BOOL(^)(CGSize size))block {
    return [OCAPredicate predicateForClass:[NSValue class] block:^BOOL(NSValue *value) {
        CGSize size;
        BOOL success = [value unboxValue:&size objCType:@encode(CGSize)];
        if ( ! success) return NO;
        
        return block(size);
    }];
}


+ (NSPredicate *)isSizeEqualTo:(CGSize)otherSize {
    return [OCAPredicate predicateForSize:^BOOL(CGSize size) {
        return CGSizeEqualToSize(size, otherSize);
    }];
}


+ (NSPredicate *)isSizeZero {
    return [OCAPredicate isSizeEqualTo:CGSizeZero];
}





@end


