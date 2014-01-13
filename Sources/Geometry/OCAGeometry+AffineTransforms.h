//
//  OCAGeometry+AffineTransforms.h
//  Objective-Chain
//
//  Created by Martin Kiss on 13.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAGeometry+Base.h"





@interface OCAGeometry (AffineTransforms)





#pragma mark -
#pragma mark Predicates
#pragma mark -

+ (NSPredicate *)predicateForAffineTransform:(BOOL(^)(CGAffineTransform t))block;
+ (NSPredicate *)affineTransformIsIdentity;
+ (NSPredicate *)affineTransformIsEqualTo:(CGAffineTransform)otherAffineTransform;



#pragma mark -
#pragma mark Transformers
#pragma mark -


#pragma mark Creating Affine Transforms

+ (OCATransformer *)affineTransformFromScale;
+ (OCATransformer *)affineTransformFromRotation;
+ (OCATransformer *)affineTransformFromTranslation;
+ (OCATransformer *)affineTransformFromString;


#pragma mark Modifying Affine Transforms

+ (OCATransformer *)modifyAffineTransform:(CGAffineTransform(^)(CGAffineTransform t))block;
+ (OCATransformer *)concatAffineTransform:(CGAffineTransform)otherAffineTransform;
+ (OCATransformer *)affineTransformScale:(CGSize)scale;
+ (OCATransformer *)affineTransformRotate:(CGFloat)rotation;
+ (OCATransformer *)affineTransformTranslate:(CGPoint)translation;
+ (OCATransformer *)invertAffineTransform;


#pragma mark Disposing Affine Transforms

+ (OCATransformer *)stringFromAffineTransform;
+ (OCATransformer *)affineTransformGetScale;
+ (OCATransformer *)affineTransformGetRotation;
+ (OCATransformer *)affineTransformGetTranslation;





@end





#pragma mark -
#pragma mark Functions
#pragma mark -

extern CGSize OCAAffineTransformGetScale(CGAffineTransform);
extern CGSize OCAAffineTransformGetRotation(CGAffineTransform);
extern CGSize OCAAffineTransformGetTranslation(CGAffineTransform);


