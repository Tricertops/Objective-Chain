//
//  OCAControlTarget.h
//  Objective-Chain
//
//  Created by Martin Kiss on 15.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCAProducer.h"





@interface OCAControlTarget : OCAProducer



- (instancetype)initWithControl:(UIControl *)control events:(UIControlEvents)events;

@property (atomic, readonly, weak) UIControl *control;
@property (atomic, readonly, assign) UIControlEvents events;



@end





@interface UIControl (OCAControlTarget)


- (OCAControlTarget *)producerForEvent:(UIControlEvents)event;
//TODO: producerForTouchUpInside
//TODO: producerForValueChanged


@end


