//
//  OCATimer.h
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAProducer.h"
#import "OCAQueue.h"





/*!
 Timer is a Producer, that periodically sends dates (\c NSDate instances).
 !*/
@interface OCATimer : OCAProducer





#pragma mark Creating Timer


/*!
 Designated initializer for a Timer producer.
 
 @param owner       Object that created the timer or \c nil. Lifetime of the timer will be tied with the owner, so when the owner deallocates, the timer will stop.
 @param targetQueue Queue on which the timer produces values – instances of \c NSDate. If \c nil, default background queue is used.
 @param startDate   Date on which the timer fires for the first time. If \c nil, current time is used.
 @param interval    Time interval for repeating timer. If zero or negative, the timer fires only once.
 @param leeway      The amount of time, that the timer can defer fire.
 @param endDate     Date on which the timer stops itself and no new values are produced. May be \c nil, in which case the timer never stops itself.
 
 @discussion
 To create non-repeating timer, use interval of zero or use endDate the same as startDate.
 
 The timer uses targetQueue to create its own private serial queue to send values. This ensures, that they are delivered serially, even when the target queue is concurrent.
 
 Timer can be stopped in 3 ways:
 
    1. Its owner deallocates.
    2. End date is reached.
    3. You call the \c -stop method.
 !*/
- (instancetype)initWithOwner:(id)owner
                        queue:(OCAQueue *)targetQueue
                    startDate:(NSDate *)startDate
                     interval:(NSTimeInterval)interval
                       leeway:(NSTimeInterval)leeway
                      endDate:(NSDate *)endDate;

//! Creates timer, that fires only once at the given \c fireDate.
+ (instancetype)fireAt:(NSDate *)fireDate;

/*!
 Creates timer that repeats each \c seconds with optional owner.
 
 @see -[OCATimer initWithOwner:queue:startDate:interval:leeway:endDate:]
 !*/
+ (instancetype)repeat:(NSTimeInterval)seconds owner:(id)owner;

//! Creates timer that repeats each \c seconds with optional end date.
+ (instancetype)repeat:(NSTimeInterval)seconds until:(NSDate *)date;



#pragma mark Attributes of Timer

//! Owner of the timer. When the owner deallocates, the timer will stop.
@property (atomic, readonly, weak) id owner;

//! Queue of on which the timer sends values, this is not the queue passed during initialization, but rather a new one, that is targetted to it.
@property (atomic, readonly, strong) OCAQueue *queue;

//! Date on which the timer fires first time.
@property (atomic, readonly, copy) NSDate *startDate;

//! Interval for repeating timer. May be delayed by \c leeway.
@property (atomic, readonly, assign) NSTimeInterval interval;

//! Allowed amount of time the timer can be deferred.
@property (atomic, readonly, assign) NSTimeInterval leeway;

//! Date on which the timer stops itself.
@property (atomic, readonly, copy) NSDate *endDate;


#pragma mark Controlling Timer


//! Flag whether the receiver didn't stop yet.
@property (atomic, readonly, assign) BOOL isRunning;

//! Stops the timer and finishes production of values. The timer is internally released and if there is no other strong reference, it is deallocated.
- (void)stop;


//TODO: -pause
//TODO: -resume



@end


