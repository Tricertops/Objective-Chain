//
//  OCATransformer+CGAffineTransform.m
//  Objective-Chain
//
//  Created by Martin Kiss on 13.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer+CGAffineTransform.h"
#import "OCAGeometry+Functions.h"
#import "OCATransformer+CGPoint.h"
#import "OCATransformer+CGSize.h"

#if OCA_iOS
    #import <UIKit/UIGeometry.h>
#endif





@implementation OCATransformer (CGAffineTransform)





#pragma mark Creating Affine Transforms


+ (OCATransformer *)affineTransformFromScale {
    return [[OCATransformer fromClass:[NSNumber class] toClass:[NSValue class]
                            asymetric:^NSValue *(NSNumber *input) {
                                
                                CGFloat scale = input.doubleValue;
                                CGAffineTransform t = CGAffineTransformMakeScale(scale, scale);
                                return OCABox(t);
                            }]
            describe:@"affine transform from scale"];
}


+ (OCATransformer *)affineTransformFromScales {
    return [[OCATransformer fromClass:[NSValue class] toClass:[NSValue class]
                           transform:^NSValue *(NSValue *input) {
                               
                               CGSize scale = OCAUnbox(input, CGSize, CGSizeMake(1, 1));
                               CGAffineTransform t = CGAffineTransformMakeScale(scale.width, scale.height);
                               return OCABox(t);
                               
                           } reverse:^NSValue *(NSValue *input) {
                               
                               CGAffineTransform t = OCAUnbox(input, CGAffineTransform, CGAffineTransformIdentity);
                               CGSize scale = CGSizeMake(sqrt(t.a*t.a + t.c*t.c),
                                                         sqrt(t.b*t.b + t.d*t.d));
                               return OCABox(scale);
                           }]
            describe:@"affine transform from scales"
            reverse:@"scales from affine transform"];
}


+ (OCATransformer *)affineTransformFromRotation {
    return [[OCATransformer fromClass:[NSNumber class] toClass:[NSValue class]
                            transform:^NSValue *(NSNumber *input) {
                                
                                CGAffineTransform t = CGAffineTransformMakeRotation(input.doubleValue);
                                return OCABox(t);
                                
                            } reverse:^NSNumber *(NSValue *input) {
                                
                                CGAffineTransform t = OCAUnbox(input, CGAffineTransform, CGAffineTransformIdentity);
                                return @( atan2(t.b, t.a) );
                            }]
            describe:@"affine transform from rotation"
            reverse:@"rotation from affine transform"];
}


+ (OCATransformer *)affineTransformFromTranslation {
    return [[OCATransformer fromClass:[NSValue class] toClass:[NSValue class]
                            transform:^NSValue *(NSValue *input) {
                                
                                CGPoint translation = OCAUnboxPoint(input);
                                CGAffineTransform t = CGAffineTransformMakeTranslation(translation.x, translation.y);
                                return OCABox(t);
                                
                            } reverse:^NSValue *(NSValue *input) {
                                
                                CGAffineTransform t = OCAUnbox(input, CGAffineTransform, CGAffineTransformIdentity);
                                CGPoint translation = CGPointMake(t.tx, t.ty);
                                return OCABox(translation);
                            }]
            describe:@"affine transform from translation"
            reverse:@"translation from affine transform"];
}


#if OCA_iOS
+ (OCATransformer *)affineTransformFromString {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSValue class]
                            transform:^NSValue *(NSString *input) {
                                
                                return OCABox(CGAffineTransformFromString(input));
                                
                            } reverse:^NSString *(NSValue *input) {
                                
                                CGAffineTransform t = OCAUnbox(input, CGAffineTransform, CGAffineTransformIdentity);
                                return NSStringFromCGAffineTransform(t);
                            }]
            describe:@"affine transform from string"
            reverse:@"string from affine transform"];
}
#endif





#pragma mark Modifying Affine Transforms


+ (OCATransformer *)modifyAffineTransform:(CGAffineTransform(^)(CGAffineTransform t))block {
    return [[OCATransformer fromClass:[NSValue class] toClass:[NSValue class]
                            asymetric:^NSValue *(NSValue *input) {
                                
                                CGAffineTransform t = OCAUnbox(input, CGAffineTransform, CGAffineTransformIdentity);
                                t = block(t);
                                return OCABox(t);
                            }]
            describe:@"modify affine transform"];
}


+ (OCATransformer *)modifyAffineTransform:(CGAffineTransform(^)(CGAffineTransform t))block reverse:(CGAffineTransform(^)(CGAffineTransform t))reverseBlock {
    return [[OCATransformer fromClass:[NSValue class] toClass:[NSValue class]
                           transform:^NSValue *(NSValue *input) {
                               
                               CGAffineTransform t = OCAUnbox(input, CGAffineTransform, CGAffineTransformIdentity);
                               t = block(t);
                               return OCABox(t);
                               
                           } reverse:^NSValue *(NSValue *input) {
                               
                               CGAffineTransform t = OCAUnbox(input, CGAffineTransform, CGAffineTransformIdentity);
                               t = reverseBlock(t);
                               return OCABox(t);
                           }]
            describe:@"modify affine transform"];
}


+ (OCATransformer *)concatAffineTransform:(CGAffineTransform)otherAffineTransform {
    return [[OCATransformer modifyAffineTransform:^CGAffineTransform(CGAffineTransform t) {
        
        return CGAffineTransformConcat(t, otherAffineTransform);
    }]
            describe:@"concat other affine transform"];
}


+ (OCATransformer *)affineTransformScale:(CGSize)scale {
    return [[OCATransformer modifyAffineTransform:^CGAffineTransform(CGAffineTransform t) {
        
        return CGAffineTransformScale(t, scale.width, scale.height);
        
    } reverse:^CGAffineTransform(CGAffineTransform t) {
        
        return CGAffineTransformScale(t, 1 / scale.width, 1 / scale.height);
    }]
            describe:[NSString stringWithFormat:@"scale affine transform by %@", OCAStringFromSize(scale)]
            reverse:[NSString stringWithFormat:@"scale affine transform by %@", OCAStringFromSize(CGSizeMake(1 / scale.width, 1 / scale.height))]];
}


+ (OCATransformer *)affineTransformRotate:(CGFloat)rotation {
    return [[OCATransformer modifyAffineTransform:^CGAffineTransform(CGAffineTransform t) {
        
        return CGAffineTransformRotate(t, rotation);
        
    } reverse:^CGAffineTransform(CGAffineTransform t) {
        
        return CGAffineTransformRotate(t, -rotation);
    }]
            describe:[NSString stringWithFormat:@"rotate affine transform by %@", @(rotation)]
            reverse:[NSString stringWithFormat:@"rotate affine transform by %@", @(rotation)]];
}


+ (OCATransformer *)affineTransformTranslate:(CGPoint)translation {
    return [[OCATransformer modifyAffineTransform:^CGAffineTransform(CGAffineTransform t) {
        
        return CGAffineTransformTranslate(t, translation.x, translation.y);
        
    } reverse:^CGAffineTransform(CGAffineTransform t) {
        
        return CGAffineTransformTranslate(t, -translation.x, -translation.y);
    }]
            describe:[NSString stringWithFormat:@"translate affine transform by %@", OCAStringFromPoint(translation)]
            reverse:[NSString stringWithFormat:@"translate affine transform by %@", OCAStringFromPoint(CGPointMake(-translation.x, -translation.y))]];
}


+ (OCATransformer *)invertAffineTransform {
    return [[OCATransformer modifyAffineTransform:^CGAffineTransform(CGAffineTransform t) {
        
        return CGAffineTransformInvert(t);
        
    } reverse:^CGAffineTransform(CGAffineTransform t) {
        
        return CGAffineTransformInvert(t);
    }]
            describe:@"invert affine transform"
            reverse:@"invert affine transform"];
}





@end


