//
//  OCAGeometry+Points.h
//  Objective-Chain
//
//  Created by Martin Kiss on 13.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAGeometry+Base.h"





@interface OCAGeometry (Points)





#pragma mark -
#pragma mark Predicates
#pragma mark -

+ (NSPredicate *)predicateForPoint:(BOOL(^)(CGPoint point))block;
+ (NSPredicate *)isPointEqualTo:(CGPoint)otherPoint;
+ (NSPredicate *)isPointZero;
+ (NSPredicate *)isPointFurtherFrom:(CGPoint)otherPoint than:(CGFloat)distance;
+ (NSPredicate *)isPointCloserTo:(CGPoint)otherPoint than:(CGFloat)distance;



#pragma mark -
#pragma mark Transformers
#pragma mark -


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


#pragma mark Disposing Points

+ (OCATransformer *)stringFromPoint;
+ (OCATransformer *)distanceToPoint:(CGPoint)otherPoint;
+ (OCATransformer *)pointMagnitude;
+ (OCATransformer *)pointAngle;





@end





#pragma mark -
#pragma mark Functions
#pragma mark -

extern CGPoint OCAPointFromString(NSString *);
extern NSString * OCAStringFromPoint(CGPoint);

extern CGPoint OCAPointAddPoint(CGPoint, CGPoint);
extern CGPoint OCAPointSubtractPoint(CGPoint, CGPoint);
extern CGPoint OCAPointMultiply(CGPoint point, CGFloat multipler);
extern CGPoint OCAPointNormalize(CGPoint);

extern CGPoint OCAPointRound(CGPoint point, CGFloat scale);
extern CGPoint OCAPointFloor(CGPoint point, CGFloat scale);
extern CGPoint OCAPointCeil(CGPoint point, CGFloat scale);

extern CGFloat OCAPointDistanceToPoint(CGPoint, CGPoint);
extern CGFloat OCAPointGetMagnitude(CGPoint);
extern CGFloat OCAPointGetAngle(CGPoint);


