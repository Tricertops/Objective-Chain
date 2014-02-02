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
    return [self initWithDelay:0 continuous:NO];
}


- (instancetype)initWithDelay:(NSTimeInterval)delay continuous:(BOOL)continuous {
    self = [super initWithValueClass:nil];
    if (self) {
        OCAAssert(delay >= 0, @"I am not a time traveller.") delay = 0;
        
        self->_delay = delay;
        self->_isContinuous = continuous;
        
        OCAWeakify(self);
        self.subscriber = [[OCASubscriber alloc] initWithValueClass:nil
                                                       valueHandler:^(id value) {
                                                           OCAStrongify(self);
                                                           
                                                           [self produceValue:self.lastThrottledValue];
                                                           self.lastThrottledValue = nil;
                                                           self.timer = nil;
                                                           self.isThrottled = NO;
                                                           
                                                       } finishHandler:nil];
    }
    return self;
}


+ (OCAThrottle *)throttleWithDelay:(NSTimeInterval)delay {
    return [[self alloc] initWithDelay:delay continuous:NO];
}


+ (OCAThrottle *)throttleWithDelay:(NSTimeInterval)delay continuous:(BOOL)continuous {
    return [[self alloc] initWithDelay:delay continuous:continuous];
}





#pragma mark Lifetime of Throttle


- (void)consumeValue:(id)value {
    if (self.delay == 0) {
        [self produceValue:value];
        return;
    }
    
    if (self.isContinuous && self.timer.isRunning) return;
        
    [self.timer stop];
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:self.delay];
    self.timer = [[OCATimer alloc] initWithOwner:self queue:nil startDate:fireDate interval:0 leeway:0 endDate:nil];
    self.isThrottled = YES;
    self.lastThrottledValue = value;
    [self.timer addConsumer:self.subscriber];
}


- (void)finishConsumingWithError:(NSError *)error {
    [self.timer stop];
    self.isThrottled = NO;
    self.lastThrottledValue = nil;
    [self finishProducingWithError:error];
}









@end


