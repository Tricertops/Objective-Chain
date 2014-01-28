//
//  OCAPredicate+CGRect.m
//  Objective-Chain
//
//  Created by Martin Kiss on 28.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAPredicate+CGRect.h"
#import "OCAGeometry+Functions.h"










@implementation OCAPredicate (CGRect)





+ (NSPredicate *)predicateForRect:(BOOL(^)(CGRect rect))block {
    return [OCAPredicate predicateForClass:[NSValue class] block:^BOOL(NSValue *value) {
        CGRect rect;
        BOOL success = [value unboxValue:&rect objCType:@encode(CGRect)];
        if ( ! success) return NO;
        
        return block(rect);
    }];
}


+ (NSPredicate *)isRectEqualTo:(CGRect)otherRect {
    return [OCAPredicate predicateForRect:^BOOL(CGRect rect) {
        return CGRectEqualToRect(rect, otherRect);
    }];
}


+ (NSPredicate *)isRectZero {
    return [OCAPredicate isRectEqualTo:CGRectZero];
}


+ (NSPredicate *)isRectEmpty {
    return [OCAPredicate predicateForRect:^BOOL(CGRect rect) {
        return CGRectIsEmpty(rect);
    }];
}


+ (NSPredicate *)isRectNull {
    return [OCAPredicate predicateForRect:^BOOL(CGRect rect) {
        return CGRectIsNull(rect);
    }];
}


+ (NSPredicate *)isRectInfinite {
    return [OCAPredicate predicateForRect:^BOOL(CGRect rect) {
        return CGRectIsInfinite(rect);
    }];
}


+ (NSPredicate *)isRectContainsPoint:(CGPoint)point {
    return [OCAPredicate predicateForRect:^BOOL(CGRect rect) {
        return CGRectContainsPoint(rect, point);
    }];
}


+ (NSPredicate *)isRectContainsRect:(CGRect)otherRect {
    return [OCAPredicate predicateForRect:^BOOL(CGRect rect) {
        return CGRectContainsRect(rect, otherRect);
    }];
}


+ (NSPredicate *)isRectContainedInRect:(CGRect)otherRect {
    return [OCAPredicate predicateForRect:^BOOL(CGRect rect) {
        return CGRectContainsRect(otherRect, rect);
    }];
}


+ (NSPredicate *)isRectIntersects:(CGRect)otherRect {
    return [OCAPredicate predicateForRect:^BOOL(CGRect rect) {
        return CGRectIntersectsRect(rect, otherRect);
    }];
}





@end


