//
//  OCATransformer+CGPoint.h
//  Objective-Chain
//
//  Created by Martin Kiss on 13.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <CoreGraphics/CGGeometry.h>
#import <CoreGraphics/CGAffineTransform.h>
#import "OCATransformer+Base.h"





@interface OCATransformer (CGPoint)





#pragma mark Creating Points

+ (OCATransformer *)pointFromString;
+ (OCATransformer *)makePoint;
+ (OCATransformer *)makePointWithX:(CGFloat)x;
+ (OCATransformer *)makePointWithY:(CGFloat)y;


#pragma mark Modifying Points

+ (OCATransformer *)modifyPoint:(CGPoint(^)(CGPoint point))block;
+ (OCATransformer *)modifyPoint:(CGPoint(^)(CGPoint point))block reverse:(CGPoint(^)(CGPoint point))reverseBlock;
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


