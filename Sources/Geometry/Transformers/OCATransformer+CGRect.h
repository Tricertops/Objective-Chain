//
//  OCATransformer+CGRect.h
//  Objective-Chain
//
//  Created by Martin Kiss on 13.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <CoreGraphics/CGGeometry.h>
#import <CoreGraphics/CGAffineTransform.h>
#import "OCATransformer+Base.h"

#if OCA_iOS
    #import <UIKit/UIGeometry.h>
#endif





@interface OCATransformer (CGRect)





#pragma mark -
#pragma mark Transformers
#pragma mark -


#pragma mark Creating Rectangles

+ (OCATransformer *)rectFromString;
+ (OCATransformer *)rectFromSizeWith:(CGPoint)origin;
+ (OCATransformer *)rectFromPointWith:(CGSize)size;


#pragma mark Modifying Rectangles

+ (OCATransformer *)modifyRect:(CGRect(^)(CGRect rect))block;
+ (OCATransformer *)modifyRect:(CGRect(^)(CGRect rect))block reverse:(CGRect(^)(CGRect rect))reverseBlock;
#if OCA_iOS
+ (OCATransformer *)insetRect:(UIEdgeInsets)insets;
#endif
+ (OCATransformer *)transformRect:(CGAffineTransform)affineTransform;
+ (OCATransformer *)roundRectTo:(CGFloat)scale;
+ (OCATransformer *)floorRectTo:(CGFloat)scale;
+ (OCATransformer *)ceilRectTo:(CGFloat)scale;
+ (OCATransformer *)unionWith:(CGRect)otherRect;
+ (OCATransformer *)intersectionWith:(CGRect)otherRect;
+ (OCATransformer *)standardizeRect;


#pragma mark Disposing Rectangles

+ (OCATransformer *)stringFromRect;
+ (OCATransformer *)rectRelativePoint:(CGPoint)relativePoint;
+ (OCATransformer *)rectCenter;
+ (OCATransformer *)rectEdge:(CGRectEdge)edge;





@end


