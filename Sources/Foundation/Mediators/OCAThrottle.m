//
//  OCAThrottle.m
//  Objective-Chain
//
//  Created by Martin Kiss on 2.2.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAThrottle.h"
#import "OCAProducer+Subclass.h"
#import "OCATimer.h"
#import "OCASubscriber.h"





@interface OCAThrottle ()


@property (atomic, readwrite, strong) OCATimer *timer;
@property (atomic, readwrite, assign) BOOL isThrottled;
@property (atomic, readwrite, strong) id lastThrottledValue;
@property (atomic, readwrite, strong) OCASubscriber *subscriber;


@end










@implementation OCAThrottle





#pragma mark Creating Throttle


- (instancetype)initWithValueClass:(Class)valueClass {
    return [self initWithInterval:0 continuous:NO];
}


- (instancetype)initWithInterval:(NSTimeInterval)interval continuous:(BOOL)continuous {
    self = [super initWithValueClass:nil];
    if (self) {
        OCAAssert(interval >= 0, @"I am not a time traveller.") interval = 0;
        
        self->_interval = interval;
        self->_isContinuous = continuous;
        
        OCAWeakify(self);
        self.subscriber = [[OCASubscriber alloc] initWithValueClass:nil
                                                       valueHandler:^(id value) {
                                                           OCAStrongify(self);
                                                           
                                                           self.timer = nil;
                                                           self.isThrottled = NO;
                                                           [self produceValue:self.lastThrottledValue];
                                                           self.lastThrottledValue = nil;
                                                           
                                                       } finishHandler:nil];
    }
    return self;
}


+ (OCAThrottle *)throttleWithInterval:(NSTimeInterval)delay {
    return [[self alloc] initWithInterval:delay continuous:NO];
}


+ (OCAThrottle *)throttleWithInterval:(NSTimeInterval)delay continuous:(BOOL)continuous {
    return [[self alloc] initWithInterval:delay continuous:continuous];
}





#pragma mark Lifetime of Throttle


- (void)consumeValue:(id)value {
    if (self.interval == 0) {
        [self produceValue:value];
        return;
    }
    
    self.lastThrottledValue = value;
    if (self.isContinuous && self.timer.isRunning) return;
    
    [self.timer stop];
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:self.interval];
    self.timer = [[OCATimer alloc] initWithOwner:self queue:nil startDate:fireDate interval:0 leeway:0 endDate:nil];
    self.isThrottled = YES;
    [self.timer addConsumer:self.subscriber];
}


- (void)finishConsumingWithError:(NSError *)error {
    [self.timer stop];
    self.isThrottled = NO;
    self.lastThrottledValue = nil;
    [self finishProducingWithError:error];
}





@end


