//
//  OCAPredicate+CGPoint.m
//  Objective-Chain
//
//  Created by Martin Kiss on 28.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAPredicate+CGPoint.h"
#import "OCAGeometry+Functions.h"










@implementation OCAPredicate (CGPoint)





+ (NSPredicate *)predicateForPoint:(BOOL(^)(CGPoint point))block {
    return [OCAPredicate predicateForClass:[NSValue class] block:^BOOL(NSValue *value) {
        CGPoint point;
        BOOL success = [value unboxValue:&point objCType:@encode(CGPoint)];
        if ( ! success)  return NO;
        
        return block(point);
    }];
}


+ (NSPredicate *)isPointEqualTo:(CGPoint)otherPoint {
    return [OCAPredicate predicateForPoint:^BOOL(CGPoint point) {
        return CGPointEqualToPoint(point, otherPoint);
    }];
}


+ (NSPredicate *)isPointZero {
    return [OCAPredicate isPointEqualTo:CGPointZero];
}


+ (NSPredicate *)isPointFurtherFrom:(CGPoint)otherPoint than:(CGFloat)distance {
    return [OCAPredicate predicateForPoint:^BOOL(CGPoint point) {
        return (OCAPointDistanceToPoint(point, otherPoint) >= distance);
    }];
}


+ (NSPredicate *)isPointCloserTo:(CGPoint)otherPoint than:(CGFloat)distance {
    return [OCAPredicate predicateForPoint:^BOOL(CGPoint point) {
        return (OCAPointDistanceToPoint(point, otherPoint) <= distance);
    }];
}


+ (NSPredicate *)isPointContainedInRect:(CGRect)rect {
    return [OCAPredicate predicateForPoint:^BOOL(CGPoint point) {
        return CGRectContainsPoint(rect, point);
    }];
}





@end


