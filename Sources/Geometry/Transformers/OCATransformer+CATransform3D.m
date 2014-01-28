//
//  OCATransformer+CATransform3D.m
//  Objective-Chain
//
//  Created by Martin Kiss on 13.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer+CATransform3D.h"
#import "OCAGeometry+Functions.h"










@implementation OCATransformer (Transform3D)





#pragma mark Creating 3D Transforms


+ (OCATransformer *)transform3DFromScaleWithZ:(CGFloat)zScale {
    return [[OCATransformer fromClass:[NSValue class] toClass:[NSValue class]
                           asymetric:^NSValue *(NSValue *input) {
                               
                               CGSize scale = OCAUnboxSize(input);
                               return OCABox(CATransform3DMakeScale(scale.width, scale.height, zScale));
                           }]
            describe:[NSString stringWithFormat:@"3D transform from scales with z %@", @(zScale)]];
}


+ (OCATransformer *)transform3DFromXRotation {
    return [[OCATransformer fromClass:[NSNumber class] toClass:[NSValue class]
                            asymetric:^NSValue *(NSNumber *input) {
                                
                                return OCABox(CATransform3DMakeRotation(input.doubleValue, 1, 0, 0));
                            }]
            describe:@"3D transform from x rotation"];
}


+ (OCATransformer *)transform3DFromYRotation {
    return [[OCATransformer fromClass:[NSNumber class] toClass:[NSValue class]
                            asymetric:^NSValue *(NSNumber *input) {
                                
                                return OCABox(CATransform3DMakeRotation(input.doubleValue, 0, 1, 0));
                            }]
            describe:@"3D transform from y rotation"];
}


+ (OCATransformer *)transform3DFromZRotation {
    return [[OCATransformer fromClass:[NSNumber class] toClass:[NSValue class]
                            asymetric:^NSValue *(NSNumber *input) {
                                
                                return OCABox(CATransform3DMakeRotation(input.doubleValue, 0, 0, 1));
                            }]
            describe:@"3D transform from z rotation"];
}


+ (OCATransformer *)transform3DFromTranslationWithZ:(CGFloat)zTranslation {
    return [[OCATransformer fromClass:[NSValue class] toClass:[NSValue class]
                            asymetric:^NSValue *(NSValue *input) {
                                
                                CGPoint translation = OCAUnboxPoint(input);
                                return OCABox(CATransform3DMakeTranslation(translation.x, translation.y, zTranslation));
                            }]
            describe:@"3D transform from x rotation"];
}


+ (OCATransformer *)transform3DFromAffineTransform {
    return [[OCATransformer fromClass:[NSValue class] toClass:[NSValue class]
                            transform:^NSValue *(NSValue *input) {
                                
                                CGAffineTransform affine = OCAUnbox(input, CGAffineTransform, CGAffineTransformIdentity);
                                return OCABox(CATransform3DMakeAffineTransform(affine));
                                
                            } reverse:^NSValue *(NSValue *input) {
                                
                                CATransform3D t = OCAUnbox(input, CATransform3D, CATransform3DIdentity);
                                if ( ! CATransform3DIsAffine(t)) return nil;
                                
                                return OCABox(CATransform3DGetAffineTransform(t));
                            }]
            describe:@"3D transform from affine transform"
            reverse:@"affine transform from 3D transform"];
}





#pragma mark Modifying 3D Transforms


+ (OCATransformer *)modifyTransform3D:(CATransform3D(^)(CATransform3D t))block {
    return [OCATransformer fromClass:[NSValue class] toClass:[NSValue class]
                           asymetric:^NSValue *(NSValue *input) {
                               
                               CATransform3D t = OCAUnbox(input, CATransform3D, CATransform3DIdentity);
                               t = block(t);
                               return OCABox(t);
                           }];
}


+ (OCATransformer *)concatTransform3D:(CATransform3D)otherTransform3D {
    return [OCATransformer modifyTransform3D:^CATransform3D(CATransform3D t) {
        return CATransform3DConcat(t, otherTransform3D);
    }];
}





#pragma mark Disposing 3D Transforms


+ (OCATransformer *)affineTransformFromTransform3D {
    return [[OCATransformer transform3DFromAffineTransform] reversed];
}





@end


