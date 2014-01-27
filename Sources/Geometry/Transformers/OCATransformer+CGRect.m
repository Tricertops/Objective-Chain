//
//  OCAGeometry+Rectanges.m
//  Objective-Chain
//
//  Created by Martin Kiss on 13.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAGeometry+Rectanges.h"
#import "OCAGeometry+Points.h"
#import "OCAGeometry+Sizes.h"
#import "OCAGeometry+EdgeInsets.h"










@implementation OCAGeometry (Rectanges)





#pragma mark -
#pragma mark Predicates
#pragma mark -


+ (NSPredicate *)predicateForRect:(BOOL(^)(CGRect rect))block {
    return [OCAPredicate predicateForClass:[NSValue class] block:^BOOL(NSValue *value) {
        CGRect rect;
        BOOL success = [value unboxValue:&rect objCType:@encode(CGRect)];
        if ( ! success) return NO;
        
        return block(rect);
    }];
}


+ (NSPredicate *)isRectEqualTo:(CGRect)otherRect {
    return [OCAGeometry predicateForRect:^BOOL(CGRect rect) {
        return CGRectEqualToRect(rect, otherRect);
    }];
}


+ (NSPredicate *)isRectZero {
    return [OCAGeometry isRectEqualTo:CGRectZero];
}


+ (NSPredicate *)isRectEmpty {
    return [OCAGeometry predicateForRect:^BOOL(CGRect rect) {
        return CGRectIsEmpty(rect);
    }];
}


+ (NSPredicate *)isRectNull {
    return [OCAGeometry predicateForRect:^BOOL(CGRect rect) {
        return CGRectIsNull(rect);
    }];
}


+ (NSPredicate *)isRectInfinite {
    return [OCAGeometry predicateForRect:^BOOL(CGRect rect) {
        return CGRectIsInfinite(rect);
    }];
}


+ (NSPredicate *)isRectContainsPoint:(CGPoint)point {
    return [OCAGeometry predicateForRect:^BOOL(CGRect rect) {
        return CGRectContainsPoint(rect, point);
    }];
}


+ (NSPredicate *)isRectContainsRect:(CGRect)otherRect {
    return [OCAGeometry predicateForRect:^BOOL(CGRect rect) {
        return CGRectContainsRect(rect, otherRect);
    }];
}


+ (NSPredicate *)isRectContainedInRect:(CGRect)otherRect {
    return [OCAGeometry predicateForRect:^BOOL(CGRect rect) {
        return CGRectContainsRect(otherRect, rect);
    }];
}


+ (NSPredicate *)isRectIntersects:(CGRect)otherRect {
    return [OCAGeometry predicateForRect:^BOOL(CGRect rect) {
        return CGRectIntersectsRect(rect, otherRect);
    }];
}





#pragma mark -
#pragma mark Transformers
#pragma mark -


#pragma mark Creating Rectangles


+ (OCATransformer *)rectFromString {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSValue class]
                            transform:^NSValue *(NSString *input) {
                                
                                return OCABox(OCARectFromString(input));
                                
                            } reverse:^NSString *(NSValue *input) {
                                
                                return OCAStringFromRect(OCAUnboxRect(input));
                            }]
            describe:@"rect from string"
            reverse:@"string from rect"];
}


+ (OCATransformer *)rectFromSizeWith:(CGPoint)origin {
    return [[OCATransformer fromClass:[NSValue class] toClass:[NSValue class]
                            transform:^NSValue *(NSValue *input) {
                                
                                CGRect rect = CGRectZero;
                                rect.origin = origin;
                                rect.size = OCAUnboxSize(input);
                                return OCABox(rect);
                                
                            } reverse:^NSValue *(NSValue *input) {
                                
                                CGRect rect = OCAUnboxRect(input);
                                return OCABox(rect.size);
                            }]
            describe:[NSString stringWithFormat:@"rect from size with origin %@", OCAStringFromPoint(origin)]
            reverse:@"CGRect.size"];
}


+ (OCATransformer *)rectFromPointWith:(CGSize)size {
    return [[OCATransformer fromClass:[NSValue class] toClass:[NSValue class]
                            transform:^NSValue *(NSValue *input) {
                                
                                CGRect rect = CGRectZero;
                                rect.origin = OCAUnboxPoint(input);
                                rect.size = size;
                                return OCABox(rect);
                                
                            } reverse:^NSValue *(NSValue *input) {
                                
                                CGRect rect = OCAUnboxRect(input);
                                return OCABox(rect.origin);
                            }]
            describe:[NSString stringWithFormat:@"rect from origin with size %@", OCAStringFromSize(size)]
            reverse:@"CGRect.origin"];
}





#pragma mark Modifying Rectangles


+ (OCATransformer *)modifyRect:(CGRect(^)(CGRect rect))block {
    return [[OCATransformer fromClass:[NSValue class] toClass:[NSValue class]
                            asymetric:^NSValue *(NSValue *input) {
                                
                                CGRect rect = OCAUnboxRect(input);
                                rect = block(rect);
                                return OCABox(rect);
                            }]
            describe:@"modify rect"];
}


+ (OCATransformer *)modifyRect:(CGRect(^)(CGRect rect))block reverse:(CGRect(^)(CGRect rect))reverseBlock {
    return [[OCATransformer fromClass:[NSValue class] toClass:[NSValue class]
                            transform:^NSValue *(NSValue *input) {
                                
                                CGRect rect = OCAUnboxRect(input);
                                rect = block(rect);
                                return OCABox(rect);
                            } reverse:^NSValue *(NSValue *input) {
                                
                                CGRect rect = OCAUnboxRect(input);
                                rect = reverseBlock(rect);
                                return OCABox(rect);
                            }]
            describe:@"modify rect"];
}


#if OCA_iOS
+ (OCATransformer *)insetRect:(UIEdgeInsets)insets {
    UIEdgeInsets inversedInsets = OCAEdgeInsetsMultiply(insets, -1);
    return [[OCAGeometry modifyRect:^CGRect(CGRect rect) {
        
        return UIEdgeInsetsInsetRect(rect, insets);
        
    } reverse:^CGRect(CGRect rect) {
        
        return UIEdgeInsetsInsetRect(rect, inversedInsets);
    }]
            describe:[NSString stringWithFormat:@"inset rect %@", NSStringFromUIEdgeInsets(insets)]
            reverse:[NSString stringWithFormat:@"inset rect %@", NSStringFromUIEdgeInsets(inversedInsets)]];
}
#endif


+ (OCATransformer *)transformRect:(CGAffineTransform)affineTransform {
    CGAffineTransform invertedTransform = CGAffineTransformInvert(affineTransform);
    return [[OCAGeometry modifyRect:^CGRect(CGRect rect) {
        
        return CGRectApplyAffineTransform(rect, affineTransform);
        
    } reverse:^CGRect(CGRect rect) {
        
        return CGRectApplyAffineTransform(rect, invertedTransform);
    }]
            describe:@"apply affine transform on rect"];
}


+ (OCATransformer *)roundRectTo:(CGFloat)scale {
    return [[OCAGeometry modifyRect:^CGRect(CGRect rect) {
        
        return OCARectRound(rect, scale);
        
    } reverse:^CGRect(CGRect rect) {
        return rect;
    }]
            describe:[NSString stringWithFormat:@"round rect to %@", @(scale)]
            reverse:@"pass"];
}


+ (OCATransformer *)floorRectTo:(CGFloat)scale {
    return [[OCAGeometry modifyRect:^CGRect(CGRect rect) {
        
        return OCARectFloor(rect, scale);
        
    } reverse:^CGRect(CGRect rect) {
        return rect;
    }]
            describe:[NSString stringWithFormat:@"floor rect to %@", @(scale)]
            reverse:@"pass"];
}


+ (OCATransformer *)ceilRectTo:(CGFloat)scale {
    return [[OCAGeometry modifyRect:^CGRect(CGRect rect) {
        
        return OCARectCeil(rect, scale);
        
    } reverse:^CGRect(CGRect rect) {
        return rect;
    }]
            describe:[NSString stringWithFormat:@"ceil rect to %@", @(scale)]
            reverse:@"pass"];
}


+ (OCATransformer *)unionWith:(CGRect)otherRect {
    return [[OCAGeometry modifyRect:^CGRect(CGRect rect) {
        
        return CGRectUnion(rect, otherRect);
        
    } reverse:^CGRect(CGRect rect) {
        return rect;
    }]
            describe:[NSString stringWithFormat:@"union rect with %@", OCAStringFromRect(otherRect)]
            reverse:@"pass"];
}


+ (OCATransformer *)intersectionWith:(CGRect)otherRect {
    return [[OCAGeometry modifyRect:^CGRect(CGRect rect) {
        
        return CGRectIntersection(rect, otherRect);
        
    } reverse:^CGRect(CGRect rect) {
        return rect;
    }]
            describe:[NSString stringWithFormat:@"intersect rect with %@", OCAStringFromRect(otherRect)]
            reverse:@"pass"];
}


+ (OCATransformer *)standardizeRect {
    return [[OCAGeometry modifyRect:^CGRect(CGRect rect) {
        
        return CGRectStandardize(rect);
        
    } reverse:^CGRect(CGRect rect) {
        return rect;
    }]
            describe:@"standardize"
            reverse:@"pass"];
}





#pragma mark Disposing Rectangles


+ (OCATransformer *)stringFromRect {
    return [[OCAGeometry rectFromString] reversed];
}


+ (OCATransformer *)rectRelativePoint:(CGPoint)relativePoint {
    return [[OCATransformer fromClass:[NSValue class] toClass:[NSValue class]
                           asymetric:^NSValue *(NSValue *input) {
                               
                               CGRect rect = OCAUnboxRect(input);
                               CGPoint point = OCARectGetRelativePoint(rect, relativePoint);
                               return OCABox(point);
                           }]
            describe:[NSString stringWithFormat:@"relative point %@ from rect", OCAStringFromPoint(relativePoint)]];
}


+ (OCATransformer *)rectCenter {
    return [[OCAGeometry rectRelativePoint:CGPointMake(0.5, 0.5)]
            describe:@"center from rect"];
}


+ (OCATransformer *)rectEdge:(CGRectEdge)edge {
    NSString *edgeName = @"no";
    switch (edge) {
        case CGRectMinYEdge: edgeName = @"top"; break;
        case CGRectMinXEdge: edgeName = @"left"; break;
        case CGRectMaxXEdge: edgeName = @"right"; break;
        case CGRectMaxYEdge: edgeName = @"bottom"; break;
    }
    return [[OCATransformer fromClass:[NSValue class] toClass:[NSNumber class]
                            asymetric:^NSNumber *(NSValue *input) {
                                
                                CGRect rect = OCAUnboxRect(input);
                                return @( OCARectGetEdge(rect, edge) );
                            }]
            describe:[NSString stringWithFormat:@"%@ rect edge", edgeName]];
}





@end










#pragma mark -
#pragma mark Functions
#pragma mark -


CGRect OCARectFromString(NSString *string) {
#if OCA_iOS
    return CGRectFromString(string);
#else
    return NSRectToCGRect(NSRectFromString(string));
#endif
}


NSString * OCAStringFromRect(CGRect rect) {
#if OCA_iOS
    return NSStringFromCGRect(rect);
#else
    return NSStringFromRect(NSRectFromCGRect(rect));
#endif
}


CGRect OCARectRound(CGRect rect, CGFloat scale) {
    rect.origin = OCAPointRound(rect.origin, scale);
    rect.size = OCASizeRound(rect.size, scale);
    return rect;
}


CGRect OCARectCeil(CGRect rect, CGFloat scale) {
    rect.origin = OCAPointCeil(rect.origin, scale);
    rect.size = OCASizeCeil(rect.size, scale);
    return rect;
}


CGRect OCARectFloor(CGRect rect, CGFloat scale) {
    rect.origin = OCAPointFloor(rect.origin, scale);
    rect.size = OCASizeFloor(rect.size, scale);
    return rect;
}


CGPoint OCARectGetRelativePoint(CGRect rect, CGPoint relative) {
    CGPoint point;
    point.x = rect.origin.x + (rect.size.width * relative.x);
    point.y = rect.origin.y + (rect.size.height * relative.y);
    return point;
}


CGFloat OCARectGetEdge(CGRect rect, CGRectEdge edge) {
    CGFloat(*edgeFunction)(CGRect) = NULL;
    switch (edge) {
        case CGRectMinXEdge: edgeFunction = &CGRectGetMinX; break;
        case CGRectMaxXEdge: edgeFunction = &CGRectGetMaxX; break;
        case CGRectMinYEdge: edgeFunction = &CGRectGetMinY; break;
        case CGRectMaxYEdge: edgeFunction = &CGRectGetMaxY; break;
    }
    return edgeFunction(rect);
}


