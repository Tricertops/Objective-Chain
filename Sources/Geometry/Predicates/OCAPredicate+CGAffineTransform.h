//
//  OCAPredicate+CGAffineTransform.h
//  Objective-Chain
//
//  Created by Martin Kiss on 28.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <CoreGraphics/CGAffineTransform.h>
#import "OCAPredicate.h"





@interface OCAPredicate (CGAffineTransform)



+ (NSPredicate *)predicateForAffineTransform:(BOOL(^)(CGAffineTransform t))block;

+ (NSPredicate *)isAffineTransformEqualTo:(CGAffineTransform)otherAffineTransform;
+ (NSPredicate *)isAffineTransformIdentity;



@end


