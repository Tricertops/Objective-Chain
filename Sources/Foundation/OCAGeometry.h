//
//  OCAGeometry.h
//  Objective-Chain
//
//  Created by Martin Kiss on 13.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <CoreGraphics/CGGeometry.h>
#import <CoreGraphics/CGAffineTransform.h>
//TODO: Conditional for UIKit geometry and CoreAnimation transforms

#import "OCAObject.h"
#import "OCAPredicate.h"
#import "OCATransformer.h"





@interface OCAGeometry : OCAObject



#pragma mark -
#pragma mark Point
#pragma mark -


#pragma mark Comparing Points

+ (NSPredicate *)predicateForPoint:(BOOL(^)(CGPoint point))block;
+ (NSPredicate *)isPointEqualTo:(CGPoint)otherPoint;
+ (NSPredicate *)isPointZero;
+ (NSPredicate *)isPointFurtherFrom:(CGPoint)otherPoint than:(CGFloat)distance;
+ (NSPredicate *)isPointCloserTo:(CGPoint)otherPoint than:(CGFloat)distance;


#pragma mark Creating Points

+ (OCATransformer *)pointFromString;
+ (OCATransformer *)makePointWithX:(CGFloat)x;
+ (OCATransformer *)makePointWithY:(CGFloat)y;


#pragma mark Modifying Points

+ (OCATransformer *)modifyPoint:(CGPoint(^)(CGPoint point))block;
+ (OCATransformer *)addPoint:(CGPoint)otherPoint;
+ (OCATransformer *)subtractPoint:(CGPoint)otherPoint;
+ (OCATransformer *)multiplyPointBy:(CGFloat)multiplier;
+ (OCATransformer *)transformPoint:(CGAffineTransform)affineTransform;
+ (OCATransformer *)roundPointTo:(CGFloat)scale;
+ (OCATransformer *)floorPointTo:(CGFloat)scale;
+ (OCATransformer *)ceilPointTo:(CGFloat)scale;
+ (OCATransformer *)normalizePoint;
+ (OCATransformer *)invertPoint;


#pragma mark Disposing Points

+ (OCATransformer *)stringFromPoint;
+ (OCATransformer *)distanceToPoint:(CGPoint)otherPoint;
+ (OCATransformer *)pointMagnitude;
+ (OCATransformer *)pointAngle;



#pragma mark -
#pragma mark Size
#pragma mark -


#pragma mark Comparing Sizes

+ (NSPredicate *)predicateForSize:(BOOL(^)(CGSize size))block;
+ (NSPredicate *)isSizeEqualTo:(CGSize)otherSize;
+ (NSPredicate *)isSizeZero;


#pragma mark Creating Sizes

+ (OCATransformer *)sizeFromString;
+ (OCATransformer *)makeSizeWithWidth:(CGFloat)width;
+ (OCATransformer *)makeSizeWithHeight:(CGFloat)height;


#pragma mark Modifying Sizes

+ (OCATransformer *)modifySize:(CGSize(^)(CGSize size))block;
+ (OCATransformer *)extendSizeBy:(CGSize)otherSize;
+ (OCATransformer *)shrinkSizeBy:(CGSize)otherSize;
+ (OCATransformer *)multiplySizeBy:(CGFloat)multiplier;
+ (OCATransformer *)transformSize:(CGAffineTransform)affineTransform;
+ (OCATransformer *)roundSizeTo:(CGFloat)scale;
+ (OCATransformer *)floorSizeTo:(CGFloat)scale;
+ (OCATransformer *)ceilSizeTo:(CGFloat)scale;
+ (OCATransformer *)standardizeSize;


#pragma mark Disposing Sizes

+ (OCATransformer *)stringFromSize;
+ (OCATransformer *)sizeArea;
+ (OCATransformer *)sizeRatio;



#pragma mark -
#pragma mark Rectangle
#pragma mark -


#pragma mark Comparing Rectangles

+ (NSPredicate *)predicateForRect:(BOOL(^)(CGRect size))block;
+ (NSPredicate *)isRectEqualTo:(CGRect)otherRect;
+ (NSPredicate *)isRectZero;
+ (NSPredicate *)isRectEmpty;
+ (NSPredicate *)isRectNull;
+ (NSPredicate *)isRectInfinite;
+ (NSPredicate *)isRectContainsPoint:(CGPoint)point;
+ (NSPredicate *)isRectContainsRect:(CGRect)otherRect;
+ (NSPredicate *)isRectIntersects:(CGRect)otherRect;


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



//TODO: Edge Insets



#pragma mark -
#pragma mark Affine Transforms
#pragma mark -


#pragma mark Comparing Affine Transforms

+ (NSPredicate *)predicateForAffineTransform:(BOOL(^)(CGAffineTransform t))block;
+ (NSPredicate *)affineTransformIsIdentity;
+ (NSPredicate *)affineTransformIsEqualTo:(CGAffineTransform)otherAffineTransform;


#pragma mark Creating Affine Transforms

+ (OCATransformer *)affineTransformFromScale;
+ (OCATransformer *)affineTransformFromRotation;
+ (OCATransformer *)affineTransformFromTranslation;


#pragma mark Modifying Affine Transforms

+ (OCATransformer *)modifyAffineTransform:(CGAffineTransform(^)(CGAffineTransform t))block;
+ (OCATransformer *)concatAffineTransform:(CGAffineTransform)otherAffineTransform;
+ (OCATransformer *)affineTransformScale:(CGSize)scale;
+ (OCATransformer *)affineTransformRotate:(CGFloat)rotation;
+ (OCATransformer *)affineTransformTranslate:(CGPoint)translation;
+ (OCATransformer *)invertAffineTransform;


#pragma mark Disposing Affine Transforms

+ (OCATransformer *)affineTransformGetScale;
+ (OCATransformer *)affineTransformGetRotation;
+ (OCATransformer *)affineTransformGetTranslation;



@end





#pragma mark Point Functions

extern CGPoint OCAPointAddPoint(CGPoint, CGPoint);
extern CGPoint OCAPointSubtractPoint(CGPoint, CGPoint);
extern CGPoint OCAPointMultiply(CGPoint point, CGFloat multipler);

extern CGPoint OCAPointRound(CGPoint point, CGFloat scale);
extern CGPoint OCAPointFloor(CGPoint point, CGFloat scale);
extern CGPoint OCAPointCeil(CGPoint point, CGFloat scale);

extern CGPoint OCAPointNormalize(CGPoint);
extern CGPoint OCAPointInvert(CGPoint);
extern CGFloat OCAPointDistanceToPoint(CGPoint, CGPoint);
extern CGFloat OCAPointGetMagnitude(CGPoint);
extern CGFloat OCAPointGetAngle(CGPoint);



#pragma mark Size Functions

extern CGSize OCASizeExtendBySize(CGSize, CGSize);
extern CGSize OCASizeShrinkBySize(CGSize, CGSize);
extern CGSize OCASizeMultiply(CGSize, CGPoint);

extern CGSize OCASizeRound(CGSize size, CGFloat scale);
extern CGSize OCASizeFloor(CGSize size, CGFloat scale);
extern CGSize OCASizeCeil(CGSize size, CGFloat scale);

extern CGSize OCASizeStandardize(CGSize size, CGFloat scale);
extern CGSize OCASizeGetArea(CGSize size);
extern CGSize OCASizeGetRatio(CGSize size);



#pragma mark Rectangle Functions

extern CGRect OCARectRound(CGRect rect, CGFloat scale);
extern CGRect OCARectCeil(CGRect rect, CGFloat scale);
extern CGRect OCARectFloor(CGRect rect, CGFloat scale);

extern CGRect OCARectGetPoint(CGRect rect, CGPoint point);



#pragma mark Affine Transform Functions

extern CGSize OCAAffineTransformGetScale(CGAffineTransform);
extern CGSize OCAAffineTransformGetRotation(CGAffineTransform);
extern CGSize OCAAffineTransformGetTranslation(CGAffineTransform);


