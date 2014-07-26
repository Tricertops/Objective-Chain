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

@end





@interface UIButton (OCATargetter)

- (OCATargetter *)producer;

@end





@interface UIBarButtonItem (OCATargetter)

- (OCATargetter *)producer;

@end





@interface UIGestureRecognizer (OCATargetter)

- (OCATargetter *)producer;
- (OCAProducer *)producerForState:(UIGestureRecognizerState)state;
- (OCAProducer *)callback; // Recognized state.

@end





@interface UITextField (OCATargetter)

- (OCAProducer *)producerForText;

- (OCAProducer *)producerForEndEditing;

@end





@interface UISlider (OCATargetter)

- (OCAProducer *)producerForValue;

@end





@interface UIStepper (OCATargetter)

- (OCAProducer *)producerForValue;

@end


