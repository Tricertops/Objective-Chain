//
//  OCAPredicate+UIEdgeInsets.h
//  Objective-Chain
//
//  Created by Martin Kiss on 28.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAPredicate.h"


#if OCA_iOS

#import <UIKit/UIGeometry.h>





@interface OCAPredicate (UIEdgeInsets)



+ (NSPredicate *)predicateForEdgeInsets:(BOOL(^)(UIEdgeInsets insets))block;

+ (NSPredicate *)isEdgeInsetsEqualTo:(UIEdgeInsets)otherInsets;
+ (NSPredicate *)isEdgeInsetsZero;



@end

#endif


