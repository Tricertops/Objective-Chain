//
//  OCATargetter.h
//  Objective-Chain
//
//  Created by Martin Kiss on 15.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCAProducer.h"





@interface OCATargetter : OCAProducer



- (instancetype)initWithOwner:(id)owner;

+ (instancetype)targetForControl:(UIControl *)control events:(UIControlEvents)events;
+ (instancetype)targetForBarButtonItem:(UIBarButtonItem *)barButtonItem;
+ (instancetype)targetGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;

@property (atomic, readonly, weak) id owner;

@property (atomic, readonly, assign) SEL action;



@end





@interface UIControl (OCATargetter)

- (OCATargetter *)producerForEvent:(UIControlEvents)event;
//TODO: producerForTouchUpInside
//TODO: producerForValueChanged

@end





@interface UIBarButtonItem (OCATargetter)

- (OCATargetter *)producer;

@end





@interface UIGestureRecognizer (OCATargetter)

- (OCATargetter *)producer;

@end





@interface UITextField (OCATargetter)

- (OCAProducer *)producerForText;

- (OCAProducer *)producerForEndEditing;

@end




@interface UISlider (OCATargetter)

- (OCAProducer *)producerForValue;

@end


