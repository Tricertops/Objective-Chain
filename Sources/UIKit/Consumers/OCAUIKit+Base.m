//
//  OCAUIKit+Base.m
//  Objective-Chain
//
//  Created by Martin Kiss on 15.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAUIKit+Base.h"





@implementation OCAUIKit





#pragma mark UIButton


+ (id<OCAConsumer>)setTitleOfButton:(UIButton *)button forControlState:(UIControlState)state {
    return [OCASubscriber class:[NSString class] handler:^(NSString *input) {
        [button setTitle:input forState:state];
    }];
}


+ (id<OCAConsumer>)setAttributedTitleOfButton:(UIButton *)button forControlState:(UIControlState)state {
    return [OCASubscriber class:[NSAttributedString class] handler:^(NSAttributedString *input) {
        [button setAttributedTitle:input forState:state];
    }];
}


+ (id<OCAConsumer>)setTitleColorOfButton:(UIButton *)button forControlState:(UIControlState)state {
    return [OCASubscriber class:[UIColor class] handler:^(UIColor *input) {
        [button setTitleColor:input forState:state];
    }];
}


+ (id<OCAConsumer>)setTitleShadowColorOfButton:(UIButton *)button forControlState:(UIControlState)state {
    return [OCASubscriber class:[UIColor class] handler:^(UIColor *input) {
        [button setTitleShadowColor:input forState:state];
    }];
}


+ (id<OCAConsumer>)setImageOfButton:(UIButton *)button forControlState:(UIControlState)state {
    return [OCASubscriber class:[UIImage class] handler:^(UIImage *input) {
        [button setImage:input forState:state];
    }];
}


+ (id<OCAConsumer>)setBackgroundImageOfButton:(UIButton *)button forControlState:(UIControlState)state {
    return [OCASubscriber class:[UIImage class] handler:^(UIImage *input) {
        [button setBackgroundImage:input forState:state];
    }];
}





@end


