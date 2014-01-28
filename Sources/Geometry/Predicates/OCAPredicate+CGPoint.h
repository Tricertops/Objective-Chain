//
//  OCAPredicate+CGPoint.h
//  Objective-Chain
//
//  Created by Martin Kiss on 28.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <CoreGraphics/CGGeometry.h>
#import "OCAPredicate.h"





@interface OCAPredicate (CGPoint)



+ (NSPredicate *)predicateForPoint:(BOOL(^)(CGPoint point))block;

+ (NSPredicate *)isPointEqualTo:(CGPoint)otherPoint;
+ (NSPredicate *)isPointZero;

+ (NSPredicate *)isPointFurtherFrom:(CGPoint)otherPoint than:(CGFloat)distance;
+ (NSPredicate *)isPointCloserTo:(CGPoint)otherPoint than:(CGFloat)distance;

+ (NSPredicate *)isPointContainedInRect:(CGRect)rect;



@end


