//
//  OCATransformer+UIImage.h
//  Objective-Chain
//
//  Created by Martin Kiss on 12.5.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <UIKit/UIImage.h>
#import <UIKit/UIBezierPath.h>
#import <CoreImage/CoreImage.h>
#import "OCATransformer+Base.h"





@interface OCATransformer (UIImage)



+ (OCATransformer *)resizeImageTo:(CGSize)size scale:(CGFloat)scale;
//TODO: +resizeImageTo:mode: with UIViewContentMode

+ (OCATransformer *)clipImageTo:(UIBezierPath *)path;
+ (OCATransformer *)clipImageToCircle;

+ (OCATransformer *)setImageRenderingMode:(UIImageRenderingMode)mode;

+ (OCATransformer *)filterImage:(CIFilter *)filter, ... NS_REQUIRES_NIL_TERMINATION;



@end


