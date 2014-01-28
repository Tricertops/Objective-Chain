//
//  OCATransformer+CGPoint.m
//  Objective-Chain
//
//  Created by Martin Kiss on 13.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer+CGPoint.h"
#import "OCAGeometry+Functions.h"
#import "NSArray+Ordinals.h"










@implementation OCATransformer (CGPoint)





#pragma mark Creating Points


+ (OCATransformer *)pointFromString {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSValue class]
                           transform:^NSValue *(NSString *input) {
                               
                               return OCABox(OCAPointFromString(input));
                               
                           } reverse:^NSString *(NSValue *input) {
                               
                               return OCAStringFromPoint(OCAUnboxPoint(input));
                           }]
            describe:@"point from string"
            reverse:@"string from point"];
}


+ (OCATransformer *)makePoint {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSValue class]
                            transform:^NSValue *(NSArray *input) {
                                
                                NSNumber *x = [input oca_valueAtIndex:0];
                                NSNumber *y = [input oca_valueAtIndex:1];
                                CGPoint point = CGPointMake(x.doubleValue, y.doubleValue);
                                return OCABox(point);
                                
                            } reverse:^NSArray *(NSValue *input) {
                                
                                CGPoint point = OCAUnboxPoint(input);
                                return @[ @(point.x), @(point.y) ];
                            }]
            describe:@"point from [x, y]"
            reverse:@"[x, y] from point"];
}


+ (OCATransformer *)makePointWithX:(CGFloat)x {
    return [[OCATransformer fromClass:[NSNumber class] toClass:[NSValue class]
                            transform:^NSValue *(NSNumber *input) {
                                
                                return OCABox(CGPointMake(x, input.doubleValue));
                                
                            } reverse:^NSNumber *(NSValue *input) {
                                
                                CGPoint point = OCAUnboxPoint(input);
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
                                
                                CGPoint point = OCAUnboxPoint(input);
                                return @(point.x);
                            }]
            describe:[NSString stringWithFormat:@"point with y %@", @(y)]
            reverse:@"CGPoint.x"];
}





#pragma mark Modifying Points


+ (OCATransformer *)modifyPoint:(CGPoint(^)(CGPoint point))block {
    return [[OCATransformer fromClass:[NSValue class] toClass:[NSValue class]
                            asymetric:^NSValue *(NSValue *input) {
                                
                                CGPoint point = OCAUnboxPoint(input);
                                point = block(point);
                                return OCABox(point);
                            }]
            describe:@"modify point"];
}


+ (OCATransformer *)modifyPoint:(CGPoint(^)(CGPoint point))block reverse:(CGPoint(^)(CGPoint point))reverseBlock {
    return [[OCATransformer fromClass:[NSValue class] toClass:[NSValue class]
                            transform:^NSValue *(NSValue *input) {
                                
                                CGPoint point = OCAUnboxPoint(input);
                                point = block(point);
                                return OCABox(point);
                                
                            } reverse:^NSValue *(NSValue *input) {
                                
                                CGPoint point = OCAUnboxPoint(input);
                                point = reverseBlock(point);
                                return OCABox(point);
                                
                            }]
            describe:@"modify point"];
}


+ (OCATransformer *)addPoint:(CGPoint)otherPoint {
    return [[OCATransformer modifyPoint:^CGPoint(CGPoint point) {
        
        return OCAPointAddPoint(point, otherPoint);
        
    } reverse:^CGPoint(CGPoint point) {
        
        return OCAPointSubtractPoint(point, otherPoint);
    }]
            describe:[NSString stringWithFormat:@"add point %@", OCAStringFromPoint(otherPoint)]
            reverse:[NSString stringWithFormat:@"subtract point %@", OCAStringFromPoint(otherPoint)]];
}


+ (OCATransformer *)subtractPoint:(CGPoint)otherPoint {
    return [[OCATransformer addPoint:otherPoint] reversed];
}


+ (OCATransformer *)multiplyPointBy:(CGFloat)multiplier {
    return [[OCATransformer modifyPoint:^CGPoint(CGPoint point) {
        
        return OCAPointMultiply(point, multiplier);
        
    } reverse:^CGPoint(CGPoint point) {
        
        return OCAPointMultiply(point, 1 / multiplier);
    }]
            describe:[NSString stringWithFormat:@"multiply point by %@", @(multiplier)]
            reverse:[NSString stringWithFormat:@"multiply point by %@", @(1 / multiplier)]];
}


+ (OCATransformer *)transformPoint:(CGAffineTransform)affineTransform {
    return [[OCATransformer modifyPoint:^CGPoint(CGPoint point) {
        
        return CGPointApplyAffineTransform(point, affineTransform);
        
    } reverse:^CGPoint(CGPoint point) {
        
        return CGPointApplyAffineTransform(point, CGAffineTransformInvert(affineTransform));
    }]
            describe:@"apply affine transform on point"];
}


+ (OCATransformer *)roundPointTo:(CGFloat)scale {
    return [[OCATransformer modifyPoint:^CGPoint(CGPoint point) {
        
        return OCAPointRound(point, scale);
        
    } reverse:^CGPoint(CGPoint point) {
        return point;
    }]
            describe:[NSString stringWithFormat:@"round point to %@", @(scale)]
            reverse:@"pass"];
}


+ (OCATransformer *)floorPointTo:(CGFloat)scale {
    return [[OCATransformer modifyPoint:^CGPoint(CGPoint point) {
        
        return OCAPointFloor(point, scale);
        
    } reverse:^CGPoint(CGPoint point) {
        return point;
    }]
            describe:[NSString stringWithFormat:@"floor point to %@", @(scale)]
            reverse:@"pass"];
}


+ (OCATransformer *)ceilPointTo:(CGFloat)scale {
    return [[OCATransformer modifyPoint:^CGPoint(CGPoint point) {
        
        return OCAPointCeil(point, scale);
        
    } reverse:^CGPoint(CGPoint point) {
        return point;
    }]
            describe:[NSString stringWithFormat:@"ceil point to %@", @(scale)]
            reverse:@"pass"];
}


+ (OCATransformer *)normalizePoint {
    return [[OCATransformer modifyPoint:^CGPoint(CGPoint point) {
        
        return OCAPointNormalize(point);
        
    } reverse:^CGPoint(CGPoint point) {
        return point;
    }]
            describe:@"normalize point"];
}





#pragma mark Disposing Points


+ (OCATransformer *)stringFromPoint {
    return [[OCATransformer pointFromString] reversed];
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


