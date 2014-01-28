//
//  OCAUIKit+UIButton.h
//  Objective-Chain
//
//  Created by Martin Kiss on 15.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OCAObject.h"
#import "OCATransformer.h"
#import "OCASubscriber.h"





@interface OCAUIKit : OCAObject



#pragma mark UIButton

+ (id<OCAConsumer>)setTitleOfButton:(UIButton *)button forControlState:(UIControlState)state;
+ (id<OCAConsumer>)setAttributedTitleOfButton:(UIButton *)button forControlState:(UIControlState)state;
+ (id<OCAConsumer>)setTitleColorOfButton:(UIButton *)button forControlState:(UIControlState)state;
+ (id<OCAConsumer>)setTitleShadowColorOfButton:(UIButton *)button forControlState:(UIControlState)state;
+ (id<OCAConsumer>)setImageOfButton:(UIButton *)button forControlState:(UIControlState)state;
+ (id<OCAConsumer>)setBackgroundImageOfButton:(UIButton *)button forControlState:(UIControlState)state;



@end


