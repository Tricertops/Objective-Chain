//
//  OCATransformer+UIEdgeInsets.h
//  Objective-Chain
//
//  Created by Martin Kiss on 13.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//


#import "OCATransformer+Base.h"


#if OCA_iOS

#import <UIKit/UIGeometry.h>






@interface OCATransformer (UIEdgeInsets)



#pragma mark Creating Edge Insets

+ (OCATransformer *)edgeInsetsFromEdges:(UIRectEdge)edges;
+ (OCATransformer *)edgeInsetsFromString;


#pragma mark Modifying Edge Insets

+ (OCATransformer *)modifyEdgeInsets:(UIEdgeInsets(^)(UIEdgeInsets insets))block;
+ (OCATransformer *)modifyEdgeInsets:(UIEdgeInsets(^)(UIEdgeInsets insets))block reverse:(UIEdgeInsets(^)(UIEdgeInsets insets))reverseBlock;
+ (OCATransformer *)addEdgeInsets:(UIEdgeInsets)otherInsets;
+ (OCATransformer *)subtractEdgeInsets:(UIEdgeInsets)otherInsets;
+ (OCATransformer *)multiplyEdgeInsets:(CGFloat)multiplier;
+ (OCATransformer *)roundEdgeInsetsTo:(CGFloat)scale;
+ (OCATransformer *)ceilEdgeInsetsTo:(CGFloat)scale;
+ (OCATransformer *)floorEdgeInsetsTo:(CGFloat)scale;


#pragma mark Disposing Edge Insets

+ (OCATransformer *)stringFromEdgeInsets;
+ (OCATransformer *)edgeInsetsGetHorizontal;
+ (OCATransformer *)edgeInsetsGetVertical;



@end

#endif // OCA_iOS


