//
//  OCAThrottle.h
//  Objective-Chain
//
//  Created by Martin Kiss on 2.2.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAMediator.h"





@interface OCAThrottle : OCAMediator


- (instancetype)initWithDelay:(NSTimeInterval)delay continuous:(BOOL)continuous;

+ (OCAThrottle *)throttleWithDelay:(NSTimeInterval)delay;
+ (OCAThrottle *)throttleWithDelay:(NSTimeInterval)delay continuous:(BOOL)continuous;

@property (atomic, readonly, assign) NSTimeInterval delay;
@property (atomic, readonly, assign) BOOL isContinuous;

@property (atomic, readonly, assign) BOOL isThrottled;
@property (atomic, readonly, strong) id lastThrottledValue;


@end


