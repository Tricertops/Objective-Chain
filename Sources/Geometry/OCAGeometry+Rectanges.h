//
//  OCAGeometry+Rectanges.h
//  Objective-Chain
//
//  Created by Martin Kiss on 13.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAGeometry+Base.h"





@interface OCAGeometry (Rectanges)





#pragma mark -
#pragma mark Predicates
#pragma mark -

+ (NSPredicate *)predicateForRect:(BOOL(^)(CGRect size))block;
+ (NSPredicate *)isRectEqualTo:(CGRect)otherRect;
+ (NSPredicate *)isRectZero;
+ (NSPredicate *)isRectEmpty;
+ (NSPredicate *)isRectNull;
+ (NSPredicate *)isRectInfinite;
+ (NSPredicate *)isRectContainsPoint:(CGPoint)point;
+ (NSPredicate *)isRectContainsRect:(CGRect)otherRect;
+ (NSPredicate *)isRectIntersects:(CGRect)otherRect;



#pragma mark -
#pragma mark Transformers
#pragma mark -


#pragma mark Creating Rectangles

+ (OCATransformer *)rectFromString;
+ (OCATransformer *)rectFromSizeWith:(CGPoint)origin;
+ (OCATransformer *)rectFromPointWith:(CGSize)size;


#pragma mark Modifying Rectangles

+ (OCATransformer *)modifyRect:(CGRect(^)(CGRect rect))block;
//TODO: + (OCATransformer *)insetRect:(UIEdgeInsets)insets;
+ (OCATransformer *)transformRect:(CGAffineTransform)affineTransform;
+ (OCATransformer *)roundRectTo:(CGFloat)scale;
+ (OCATransformer *)floorRectTo:(CGFloat)scale;
+ (OCATransformer *)ceilRectTo:(CGFloat)scale;
+ (OCATransformer *)unionWith:(CGRect)otherRect;
+ (OCATransformer *)intersectionWith:(CGRect)otherRect;
+ (OCATransformer *)standardizeRect;


#pragma mark Disposing Rectangles

+ (OCATransformer *)stringFromRect;
+ (OCATransformer *)rectGetPoint:(CGPoint)point;
+ (OCATransformer *)rectGetCenter:(CGPoint)point;
+ (OCATransformer *)rectGetEdge:(CGRectEdge)edge;





@end





#pragma mark -
#pragma mark Functions
#pragma mark -

extern CGRect OCARectRound(CGRect rect, CGFloat scale);
extern CGRect OCARectCeil(CGRect rect, CGFloat scale);
extern CGRect OCARectFloor(CGRect rect, CGFloat scale);

extern CGRect OCARectGetPoint(CGRect rect, CGPoint point);


