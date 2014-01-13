//
//  OCAGeometry+Transform3D.h
//  Objective-Chain
//
//  Created by Martin Kiss on 13.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAGeometry+Base.h"





@interface OCAGeometry (Transform3D)





#pragma mark -
#pragma mark Predicates
#pragma mark -

//+ (NSPredicate *)predicateForTransform3D:(BOOL(^)(CATransform3D t))block;
//+ (NSPredicate *)transform3DIsIdentity;
//+ (NSPredicate *)transform3DIsEqualTo:(CATransform3D)otherTransform3D;
//+ (NSPredicate *)transform3DIsAffineTransform;



#pragma mark -
#pragma mark Transformers
#pragma mark -


#pragma mark Creating 3D Transforms

//+ (OCATransformer *)transform3DFromScaleWithZ:(CGFloat)zScale;
//+ (OCATransformer *)transform3DFromXRotation;
//+ (OCATransformer *)transform3DFromYRotation;
//+ (OCATransformer *)transform3DFromZRotation;
//+ (OCATransformer *)transform3DFromTranslationWithZ:(CGFloat)zTranslation;
//+ (OCATransformer *)transform3DFromAffineTransform;


#pragma mark Modifying 3D Transforms

//+ (OCATransformer *)modifyTransform3D:(CATransform3D(^)(CATransform3D t))block;
//+ (OCATransformer *)concatTransform3D:(CATransform3D)otherTransform3D;


#pragma mark Disposing 3D Transforms

//+ (OCATransformer *)transform3DGetAffineTransform;





@end


