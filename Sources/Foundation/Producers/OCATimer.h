//
//  OCATimer.h
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAProducer.h"
#import "OCAQueue.h"





//! Timer is a Producer, that periodically sends values (time intervals by default).
@interface OCATimer : OCAProducer





#pragma mark Creating Timer

/*!
 *  Designated initializer.
 *
 *  @param owner       Object that created the timer or nil. Lifetime of the timer will be tied with the owner, so when the owner deallocates, the timer will stop.
 *  @param targetQueue Queue on which the timer produces values – time intervals. If nil, default background queue is used.
 *  @param startDate   Date on which the timer fires for the first time. If nil, current time is used.
 *  @param interval    Time interval for repeating timer. If zero or negative, the timer fires only once.
 *  @param leeway      The amount of time, that the timer can defer fire.
 *  @param endDate     Date on which the timer stops itself and no new values are produced. May be nil, in which case the timer never stops itself.
 
 *  @discussion
 *  To create non-repeating timer, use interval of zero or use endDate the same as startDate.
 *
 *  The timer uses targetQueue to create its own private serial queue to send values. This ensures, that they are delivered serially, even if the target queue is concurrent.
 *
 *  Timer can be stopped in 3 ways:
 *
    1. Its owner deallocates.
    2. The endDate is reached.
    3. You call the -stop method.
 */
- (instancetype)initWithOwner:(id)owner
                        queue:(OCAQueue *)targetQueue
                    startDate:(NSDate *)startDate
                     interval:(NSTimeInterval)interval
                       leeway:(NSTimeInterval)leeway
                      endDate:(NSDate *)endDate;

//! Creates timer on current queue that fires only once at the given \c fireDate.
+ (instancetype)timerForDate:(NSDate *)fireDate;

//! Creates timer on current queue that repeats each \c seconds with optional owner.
+ (instancetype)timerWithInterval:(NSTimeInterval)seconds owner:(id)owner;

//! Creates timer on current queue that repeats each \c seconds with optional end date.
+ (instancetype)timerWithInterval:(NSTimeInterval)seconds untilDate:(NSDate *)date;

//! Creates timer on background queue that repeats each \c seconds with optional owner.
+ (instancetype)backgroundTimerWithInterval:(NSTimeInterval)seconds owner:(id)owner;

//! Creates timer on background queue that repeats each \c seconds with optional end date.
+ (instancetype)backgroundTimerWithInterval:(NSTimeInterval)seconds untilDate:(NSDate *)date;



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



#pragma mark Elapsed Time

//! Cumulative time intervals ever sent by the receiver.
@property (atomic, readonly, assign) NSTimeInterval elapsedTime;

//! Shorthand to produce elapsedTime property
- (OCAProducer *)produceElapsedTime;

//! Sends time that remains to the endDate property, if any.
- (OCAProducer *)produceRemainingTime;

//! Sends current instances of NSDate starting immediatelly.<
- (OCAProducer *)produceCurrentDate;




#pragma mark Controlling Timer

//! Flag whether the receiver didn't stop yet.
@property (atomic, readonly, assign) BOOL isRunning;

//! Stops the timer and finishes production of values. The timer is internally released and if there is no other strong reference, it is deallocated.
- (void)stop;



@end


