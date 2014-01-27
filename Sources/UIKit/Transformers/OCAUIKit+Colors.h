//
//  OCAUIKit+Colors.h
//  Objective-Chain
//
//  Created by Martin Kiss on 15.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAUIKit+Base.h"





@interface OCAUIKit (Colors)





#pragma mark -
#pragma mark Transformers
#pragma mark -


+ (OCATransformer *)colorFromCGColor;
+ (OCATransformer *)colorGetCGColor;

+ (OCATransformer *)colorWithAlpha:(CGFloat)alpha;





@end


