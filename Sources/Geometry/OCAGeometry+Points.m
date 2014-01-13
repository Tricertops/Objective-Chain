//
//  OCAGeometry+Points.m
//  Objective-Chain
//
//  Created by Martin Kiss on 13.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAGeometry+Points.h"
#import "OCAPredicate.h"
#import "OCAMath.h"










@implementation OCAGeometry (Points)





#pragma mark -
#pragma mark Predicates
#pragma mark -


+ (NSPredicate *)predicateForPoint:(BOOL(^)(CGPoint point))block {
    return [OCAPredicate predicateForClass:[NSValue class] block:^BOOL(NSValue *value) {
        CGPoint point = OCAUnbox(value, CGPoint, CGPointZero);
        return block(point);
    }];
}


+ (NSPredicate *)isPointEqualTo:(CGPoint)otherPoint {
    return [OCAGeometry predicateForPoint:^BOOL(CGPoint point) {
        return CGPointEqualToPoint(point, otherPoint);
    }];
}


+ (NSPredicate *)isPointZero {
    return [OCAGeometry predicateForPoint:^BOOL(CGPoint point) {
        return CGPointEqualToPoint(point, CGPointZero);
    }];
}


+ (NSPredicate *)isPointFurtherFrom:(CGPoint)otherPoint than:(CGFloat)distance {
    return [OCAGeometry predicateForPoint:^BOOL(CGPoint point) {
        return (OCAPointDistanceToPoint(point, otherPoint) >= distance);
    }];
}


+ (NSPredicate *)isPointCloserTo:(CGPoint)otherPoint than:(CGFloat)distance {
    return [OCAGeometry predicateForPoint:^BOOL(CGPoint point) {
        return (OCAPointDistanceToPoint(point, otherPoint) <= distance);
    }];
}





#pragma mark -
#pragma mark Transformers
#pragma mark -


#pragma mark Creating Points


+ (OCATransformer *)pointFromString {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSValue class]
                           transform:^NSValue *(NSString *input) {
                               
                               return OCABox(OCAPointFromString(input));
                               
                           } reverse:^NSString *(NSValue *input) {
                               
                               CGPoint point = OCAUnbox(input, CGPoint, CGPointZero);
                               return OCAStringFromPoint(point);
                           }]
            describe:@"point from string"
            reverse:@"string from point"];
}


+ (OCATransformer *)makePointWithX:(CGFloat)x {
    return [[OCATransformer fromClass:[NSNumber class] toClass:[NSValue class]
                            transform:^NSValue *(NSNumber *input) {
                                
                                return OCABox(CGPointMake(x, input.doubleValue));
                                
                            } reverse:^NSNumber *(NSValue *input) {
                                
                                CGPoint point = OCAUnbox(input, CGPoint, CGPointZero);
                                return @(point.y);
                            }]
            describe:[NSString stringWithFormat:@"point with x %@", @(x)]
            reverse:@"CGPoint.y"];
}


+ (OCATransformer *)makePointWithY:(CGFloat)y {
    return [[OCATransformer fromClass:[NSNumber class] toClass:[NSValue class]
                            transform:^NSValue *(NSNumber *input) {
                                
                                return OCABox(CGPointMake(input.doubleValue, y));
                                
                            } reverse:^NSNumber *(NSValue *input) {
                                
                                CGPoint point = OCAUnbox(input, CGPoint, CGPointZero);
                                return @(point.x);
                            }]
            describe:[NSString stringWithFormat:@"point with y %@", @(y)]
            reverse:@"CGPoint.x"];
}





#pragma mark Modifying Points


+ (OCATransformer *)modifyPoint:(CGPoint(^)(CGPoint point))block {
    return [[OCATransformer fromClass:[NSValue class] toClass:[NSValue class]
                            asymetric:^NSValue *(NSValue *input) {
                                
                                CGPoint point = OCAUnbox(input, CGPoint, CGPointZero);
                                point = block(point);
                                return OCABox(point);
                            }]
            describe:@"modify point"];
}


+ (OCATransformer *)addPoint:(CGPoint)otherPoint {
    return [OCAGeometry modifyPoint:^CGPoint(CGPoint point) {
        return OCAPointAddPoint(point, otherPoint);
    }];
}


+ (OCATransformer *)subtractPoint:(CGPoint)otherPoint {
    return [OCAGeometry modifyPoint:^CGPoint(CGPoint point) {
        return OCAPointSubtractPoint(point, otherPoint);
    }];
}


+ (OCATransformer *)multiplyPointBy:(CGFloat)multiplier {
    return [OCAGeometry modifyPoint:^CGPoint(CGPoint point) {
        return OCAPointMultiply(point, multiplier);
    }];
}


+ (OCATransformer *)transformPoint:(CGAffineTransform)affineTransform {
    return [OCAGeometry modifyPoint:^CGPoint(CGPoint point) {
        return CGPointApplyAffineTransform(point, affineTransform);
    }];
}


+ (OCATransformer *)roundPointTo:(CGFloat)scale {
    return [OCAGeometry modifyPoint:^CGPoint(CGPoint point) {
        return OCAPointRound(point, scale);
    }];
}


+ (OCATransformer *)floorPointTo:(CGFloat)scale {
    return [OCAGeometry modifyPoint:^CGPoint(CGPoint point) {
        return OCAPointFloor(point, scale);
    }];
}


+ (OCATransformer *)ceilPointTo:(CGFloat)scale {
    return [OCAGeometry modifyPoint:^CGPoint(CGPoint point) {
        return OCAPointCeil(point, scale);
    }];
}


+ (OCATransformer *)normalizePoint {
    return [OCAGeometry modifyPoint:^CGPoint(CGPoint point) {
        return OCAPointNormalize(point);
    }];
}





#pragma mark Disposing Points


+ (OCATransformer *)stringFromPoint {
    return [[OCAGeometry pointFromString] reversed];
}


+ (OCATransformer *)distanceToPoint:(CGPoint)otherPoint {
    return [[OCATransformer fromClass:[NSValue class] toClass:[NSNumber class]
                            asymetric:^NSNumber *(NSValue *input) {
                                
                                CGPoint point = OCAUnbox(input, CGPoint, CGPointZero);
                                return @( OCAPointDistanceToPoint(point, otherPoint) );
                            }]
            describe:[NSString stringWithFormat:@"distance to %@", OCAStringFromPoint(otherPoint)]];
}


+ (OCATransformer *)pointMagnitude {
    return [[OCATransformer fromClass:[NSValue class] toClass:[NSNumber class]
                            asymetric:^NSNumber *(NSValue *input) {
                                
                                CGPoint point = OCAUnbox(input, CGPoint, CGPointZero);
                                return @( OCAPointGetMagnitude(point) );
                            }]
            describe:@"magnitude of point"];
}


+ (OCATransformer *)pointAngle {
    return [[OCATransformer fromClass:[NSValue class] toClass:[NSNumber class]
                            asymetric:^NSNumber *(NSValue *input) {
                                
                                CGPoint point = OCAUnbox(input, CGPoint, CGPointZero);
                                return @( OCAPointGetAngle(point) );
                            }]
            describe:@"angle to point"];
}





@end










#pragma mark -
#pragma mark Functions
#pragma mark -


CGPoint OCAPointFromString(NSString *string) {
#if OCA_iOS
    return CGPointFromString(string);
#else
    return NSPointToCGPoint(NSPointFromString(string));
#endif
}


NSString * OCAStringFromPoint(CGPoint point) {
#if OCA_iOS
    return NSStringFromCGPoint(point);
#else
    return NSStringFromPoint(NSPointFromCGPoint(point));
#endif
}


CGPoint OCAPointAddPoint(CGPoint a, CGPoint b) {
    a.x += b.x;
    a.y += b.y;
    return a;
}


CGPoint OCAPointSubtractPoint(CGPoint a, CGPoint b) {
    a.x -= b.x;
    a.y -= b.y;
    return a;
}


CGPoint OCAPointMultiply(CGPoint p, CGFloat m) {
    p.x *= m;
    p.y *= m;
    return p;
}


CGPoint OCAPointNormalize(CGPoint p) {
    return OCAPointMultiply(p, 1 / OCAPointGetMagnitude(p));
}


CGPoint OCAPointRound(CGPoint p, CGFloat s) {
    p.x = OCARound(p.x, s);
    p.y = OCARound(p.y, s);
    return p;
}


CGPoint OCAPointFloor(CGPoint p, CGFloat s) {
    p.x = OCAFloor(p.x, s);
    p.y = OCAFloor(p.y, s);
    return p;
}


CGPoint OCAPointCeil(CGPoint p, CGFloat s) {
    p.x = OCACeil(p.x, s);
    p.y = OCACeil(p.y, s);
    return p;
}


CGFloat OCAPointDistanceToPoint(CGPoint a, CGPoint b) {
    return OCAPointGetMagnitude(OCAPointSubtractPoint(a, b));
}


CGFloat OCAPointGetMagnitude(CGPoint p) {
    return sqrt((p.x * p.x) + (p.y * p.y));
}


CGFloat OCAPointGetAngle(CGPoint p) {
    return atan2(p.x, p.y);
}


