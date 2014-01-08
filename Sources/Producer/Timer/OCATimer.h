//
//  OCATimer.h
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAProducer.h"

@class OCAQueue;





/// Timer is a Producer, that periodically sends current dates.
@interface OCATimer : OCAProducer



#pragma mark Creating Timer

- (instancetype)initWithTarget:(OCAQueue *)targetQueue
                         delay:(NSTimeInterval)delay
                      interval:(NSTimeInterval)interval
                        leeway:(NSTimeInterval)leeway
                         count:(NSUInteger)count;

+ (instancetype)timerWithInterval:(NSTimeInterval)interval;
+ (instancetype)timerWithInterval:(NSTimeInterval)interval count:(NSUInteger)count;

+ (instancetype)backgroundTimerWithInterval:(NSTimeInterval)interval;
+ (instancetype)backgroundTimerWithInterval:(NSTimeInterval)interval count:(NSUInteger)count;


#pragma mark Attributes of Timer

@property (atomic, readonly, strong) OCAQueue *queue;

@property (atomic, readonly, assign) NSTimeInterval delay;
@property (atomic, readonly, assign) NSTimeInterval interval;
@property (atomic, readonly, assign) NSTimeInterval leeway;
@property (atomic, readonly, assign) NSUInteger count;


//TODO: Until date?
//TODO: Stop


@end


