//
//  OCATransformer+UIColor.h
//  Objective-Chain
//
//  Created by Martin Kiss on 15.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <UIKit/UIColor.h>
#import "OCATransformer+Base.h"





@interface OCATransformer (UIColor)



+ (OCATransformer *)colorFromCGColor;
+ (OCATransformer *)colorGetCGColor;

+ (OCATransformer *)colorWithAlpha:(CGFloat)alpha;



@end


