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

+ (OCATransformer *)affineTransformFromScales;
+ (OCATransformer *)affineTransformFromRotation;
+ (OCATransformer *)affineTransformFromTranslation;
#if OCA_iOS
+ (OCATransformer *)affineTransformFromString;
#endif


#pragma mark Modifying Affine Transforms

+ (OCATransformer *)modifyAffineTransform:(CGAffineTransform(^)(CGAffineTransform t))block;
+ (OCATransformer *)modifyAffineTransform:(CGAffineTransform(^)(CGAffineTransform t))block reverse:(CGAffineTransform(^)(CGAffineTransform t))reverseBlock;
+ (OCATransformer *)concatAffineTransform:(CGAffineTransform)otherAffineTransform;
+ (OCATransformer *)affineTransformScale:(CGSize)scale;
+ (OCATransformer *)affineTransformRotate:(CGFloat)rotation;
+ (OCATransformer *)affineTransformTranslate:(CGPoint)translation;
+ (OCATransformer *)invertAffineTransform;





@end


