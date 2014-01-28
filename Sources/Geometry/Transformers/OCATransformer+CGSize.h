//
//  OCATransformer+CGSize.h
//  Objective-Chain
//
//  Created by Martin Kiss on 13.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <CoreGraphics/CGGeometry.h>
#import <CoreGraphics/CGAffineTransform.h>
#import "OCATransformer+Base.h"





@interface OCATransformer (CGSize)





#pragma mark Creating Sizes

+ (OCATransformer *)sizeFromString;
+ (OCATransformer *)makeSize;
+ (OCATransformer *)makeSizeWithWidth:(CGFloat)width;
+ (OCATransformer *)makeSizeWithHeight:(CGFloat)height;


#pragma mark Modifying Sizes

+ (OCATransformer *)modifySize:(CGSize(^)(CGSize size))block;
+ (OCATransformer *)extendSizeBy:(CGSize)otherSize;
+ (OCATransformer *)shrinkSizeBy:(CGSize)otherSize;
+ (OCATransformer *)multiplySizeBy:(CGFloat)multiplier;
+ (OCATransformer *)transformSize:(CGAffineTransform)affineTransform;
+ (OCATransformer *)roundSizeTo:(CGFloat)scale;
+ (OCATransformer *)floorSizeTo:(CGFloat)scale;
+ (OCATransformer *)ceilSizeTo:(CGFloat)scale;
+ (OCATransformer *)standardizeSize;


#pragma mark Disposing Sizes

+ (OCATransformer *)stringFromSize;
+ (OCATransformer *)sizeArea;
+ (OCATransformer *)sizeRatio;





@end


