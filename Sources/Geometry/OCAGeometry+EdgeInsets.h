//
//  OCAGeometry+EdgeInsets.h
//  Objective-Chain
//
//  Created by Martin Kiss on 13.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAGeometry+Base.h"





@interface OCAGeometry (EdgeInsets)





#pragma mark -
#pragma mark Predicates
#pragma mark -

//+ (NSPredicate *)predicateForEdgeInsets:(BOOL(^)(UIEdgeInsets insets))block;
//+ (NSPredicate *)isEdgeInsetsZero;
//+ (NSPredicate *)isEdgeInsetsEqualTo:(UIEdgeInsets)insets;



#pragma mark -
#pragma mark Transformers
#pragma mark -


#pragma mark Creating Edge Insets

//+ (OCATransformer *)edgeInsetsFromEdges:(UIRectEdge)edge;
//+ (OCATransformer *)edgeInsetsFromString;


#pragma mark Modifying Edge Insets

//+ (OCATransformer *)modifyEdgeInsets:(UIEdgeInsets(^)(UIEdgeInsets insets))block;
//+ (OCATransformer *)addEdgeInsets:(UIEdgeInsets)otherInsets;
//+ (OCATransformer *)subtractEdgeInsets:(UIEdgeInsets)otherInsets;
//+ (OCATransformer *)multiplyEdgeInsets:(CGFloat)multiplier;
//+ (OCATransformer *)roundEdgeInsetsTo:(CGFloat)scale;
//+ (OCATransformer *)ceilEdgeInsetsTo:(CGFloat)scale;
//+ (OCATransformer *)floorEdgeInsetsTo:(CGFloat)scale;


#pragma mark Disposing Edge Insets

//+ (OCATransformer *)stringFromEdgeInsets;
//+ (OCATransformer *)edgeInsetsGetHorizontal;
//+ (OCATransformer *)edgeInsetsGetVertical;





@end





#pragma mark -
#pragma mark Functions
#pragma mark -

//extern UIEdgeInsets OCAEdgeInsetsAddEdgeInsets(UIEdgeInsets, UIEdgeInsets);
//extern UIEdgeInsets OCAEdgeInsetsSubtractEdgeInsets(UIEdgeInsets, UIEdgeInsets);
//extern UIEdgeInsets OCAEdgeInsetsMultiply(UIEdgeInsets insets, CGFloat multipler);

//extern UIEdgeInsets OCAEdgeInsetsRound(UIEdgeInsets insets, CGFloat scale);
//extern UIEdgeInsets OCAEdgeInsetsFloor(UIEdgeInsets insets, CGFloat scale);
//extern UIEdgeInsets OCAEdgeInsetsCeil(UIEdgeInsets insets, CGFloat scale);


