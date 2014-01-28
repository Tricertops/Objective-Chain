//
//  OCATransformer+CGRect.m
//  Objective-Chain
//
//  Created by Martin Kiss on 13.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer+CGRect.h"
#import "OCAGeometry+Functions.h"
#import "OCATransformer+CGPoint.h"
#import "OCATransformer+CGSize.h"
#import "OCATransformer+UIEdgeInsets.h"










@implementation OCATransformer (CGRect)





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
    return [[OCATransformer modifyRect:^CGRect(CGRect rect) {
        
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
    return [[OCATransformer modifyRect:^CGRect(CGRect rect) {
        
        return CGRectApplyAffineTransform(rect, affineTransform);
        
    } reverse:^CGRect(CGRect rect) {
        
        return CGRectApplyAffineTransform(rect, invertedTransform);
    }]
            describe:@"apply affine transform on rect"];
}


+ (OCATransformer *)roundRectTo:(CGFloat)scale {
    return [[OCATransformer modifyRect:^CGRect(CGRect rect) {
        
        return OCARectRound(rect, scale);
        
    } reverse:^CGRect(CGRect rect) {
        return rect;
    }]
            describe:[NSString stringWithFormat:@"round rect to %@", @(scale)]
            reverse:@"pass"];
}


+ (OCATransformer *)floorRectTo:(CGFloat)scale {
    return [[OCATransformer modifyRect:^CGRect(CGRect rect) {
        
        return OCARectFloor(rect, scale);
        
    } reverse:^CGRect(CGRect rect) {
        return rect;
    }]
            describe:[NSString stringWithFormat:@"floor rect to %@", @(scale)]
            reverse:@"pass"];
}


+ (OCATransformer *)ceilRectTo:(CGFloat)scale {
    return [[OCATransformer modifyRect:^CGRect(CGRect rect) {
        
        return OCARectCeil(rect, scale);
        
    } reverse:^CGRect(CGRect rect) {
        return rect;
    }]
            describe:[NSString stringWithFormat:@"ceil rect to %@", @(scale)]
            reverse:@"pass"];
}


+ (OCATransformer *)unionWith:(CGRect)otherRect {
    return [[OCATransformer modifyRect:^CGRect(CGRect rect) {
        
        return CGRectUnion(rect, otherRect);
        
    } reverse:^CGRect(CGRect rect) {
        return rect;
    }]
            describe:[NSString stringWithFormat:@"union rect with %@", OCAStringFromRect(otherRect)]
            reverse:@"pass"];
}


+ (OCATransformer *)intersectionWith:(CGRect)otherRect {
    return [[OCATransformer modifyRect:^CGRect(CGRect rect) {
        
        return CGRectIntersection(rect, otherRect);
        
    } reverse:^CGRect(CGRect rect) {
        return rect;
    }]
            describe:[NSString stringWithFormat:@"intersect rect with %@", OCAStringFromRect(otherRect)]
            reverse:@"pass"];
}


+ (OCATransformer *)standardizeRect {
    return [[OCATransformer modifyRect:^CGRect(CGRect rect) {
        
        return CGRectStandardize(rect);
        
    } reverse:^CGRect(CGRect rect) {
        return rect;
    }]
            describe:@"standardize"
            reverse:@"pass"];
}





#pragma mark Disposing Rectangles


+ (OCATransformer *)stringFromRect {
    return [[OCATransformer rectFromString] reversed];
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
    return [[OCATransformer rectRelativePoint:CGPointMake(0.5, 0.5)]
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


