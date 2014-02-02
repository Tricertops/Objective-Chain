//
//  OCAThrottle.h
//  Objective-Chain
//
//  Created by Martin Kiss on 2.2.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAMediator.h"





/*! Throttle is a Mediator, that reduces frequency of production. It takes a time interval and can operate in two modes:
 *    1. Non-continuous: Will forward latest value after no new value came in given time interval.
 *    2. Continuous: Will forward one latest value repeatedly after the given interval.
 */
@interface OCAThrottle : OCAMediator



#pragma mark Creating Throttle

//! Designated initializer. Pass desired interval and choose the continuation mode.
- (instancetype)initWithInterval:(NSTimeInterval)interval continuous:(BOOL)continuous;

//! Returns new Throttle with given interval and continuity.
+ (OCAThrottle *)throttleWithInterval:(NSTimeInterval)interval continuous:(BOOL)continuous;



#pragma mark State of the Throttle

//! Interval as passed to designated initializer.
@property (atomic, readonly, assign) NSTimeInterval interval;

//! Continuity flag as passed to designated initializer.
@property (atomic, readonly, assign) BOOL isContinuous;

//! Flag, that indicates whether the receiver is actually throttling a value.
@property (atomic, readonly, assign) BOOL isThrottled;

//! Last consumed value, that has not yet been forwarded.
@property (atomic, readonly, strong) id lastThrottledValue;



@end


