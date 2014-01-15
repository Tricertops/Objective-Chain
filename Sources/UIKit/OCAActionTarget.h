//
//  OCAActionTarget.h
//  Objective-Chain
//
//  Created by Martin Kiss on 15.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OCAProducer.h"





@interface OCAActionTarget : OCAProducer



- (instancetype)initWithControl:(UIControl *)control events:(UIControlEvents)events;

@property (atomic, readonly, weak) UIControl *control;
@property (atomic, readonly, assign) UIControlEvents events;



@end





@interface UIControl (OCAActionTarget)


- (OCAProducer *)producerForEvent:(UIControlEvents)event;


@end


