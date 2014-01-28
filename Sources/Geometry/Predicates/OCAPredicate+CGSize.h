//
//  OCAPredicate+CGSize.h
//  Objective-Chain
//
//  Created by Martin Kiss on 28.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <CoreGraphics/CGGeometry.h>
#import "OCAPredicate.h"





@interface OCAPredicate (CGSize)



+ (NSPredicate *)predicateForSize:(BOOL(^)(CGSize size))block;

+ (NSPredicate *)isSizeEqualTo:(CGSize)otherSize;
+ (NSPredicate *)isSizeZero;



@end


