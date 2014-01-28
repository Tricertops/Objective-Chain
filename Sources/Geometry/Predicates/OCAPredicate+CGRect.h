//
//  OCAPredicate+CGRect.h
//  Objective-Chain
//
//  Created by Martin Kiss on 28.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <CoreGraphics/CGGeometry.h>
#import "OCAPredicate.h"





@interface OCAPredicate (CGRect)



+ (NSPredicate *)predicateForRect:(BOOL(^)(CGRect rect))block;

+ (NSPredicate *)isRectEqualTo:(CGRect)otherRect;
+ (NSPredicate *)isRectZero;
+ (NSPredicate *)isRectEmpty;
+ (NSPredicate *)isRectNull;
+ (NSPredicate *)isRectInfinite;

+ (NSPredicate *)isRectContainsPoint:(CGPoint)point;
+ (NSPredicate *)isRectContainsRect:(CGRect)otherRect;
+ (NSPredicate *)isRectContainedInRect:(CGRect)otherRect;
+ (NSPredicate *)isRectIntersects:(CGRect)otherRect;



@end


