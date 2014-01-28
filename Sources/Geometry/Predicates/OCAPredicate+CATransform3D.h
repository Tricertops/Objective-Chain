//
//  OCAPredicate+CATransform3D.h
//  Objective-Chain
//
//  Created by Martin Kiss on 28.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <QuartzCore/CATransform3D.h>
#import "OCAPredicate.h"





@interface OCAPredicate (CATransform3D)



+ (NSPredicate *)predicateForTransform3D:(BOOL(^)(CATransform3D t))block;

+ (NSPredicate *)isTransform3DEqualTo:(CATransform3D)otherTransform3D;
+ (NSPredicate *)isTransform3DIdentity;

+ (NSPredicate *)isTransform3DAffineTransform;



@end


