//
//  OCATimer.m
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCATimer.h"
#import "OCAProducer+Subclass.h"
#import "OCADecomposer.h"
#import "OCABridge.h"
#import "OCAMath.h"
#import "OCAProperty.h"
#import "OCACommand.h"





@interface OCATimer ()


@property (atomic, readwrite, strong) dispatch_source_t timer;
@property (atomic, readwrite, assign) BOOL isRunning;

@property (atomic, readwrite, assign) NSTimeInterval elapsedTime;


@end










@implementation OCATimer





#pragma mark Creating Timer


- (instancetype)init {
    return [self initWithOwner:nil queue:nil startDate:nil interval:0 leeway:0 endDate:nil];
}


- (instancetype)initWithOwner:(NSObject *)owner queue:(OCAQueue *)targetQueue startDate:(NSDate *)startDate interval:(NSTimeInterval)interval leeway:(NSTimeInterval)leeway endDate:(NSDate *)endDate {
    self = [super initWithValueClass:[NSNumber class]];
    if (self) {
        OCAAssert(interval >= 0, @"Works only with positive intervals.") return nil;
        OCAAssert(leeway >= 0, @"Works only with non-negative leeway.") return nil;
        
        self->_owner = owner;
        self->_queue = [[OCAQueue alloc] initWithName:@"Timer Queue" concurrent:NO targetQueue:targetQueue ?: [OCAQueue current]];
        if (startDate) {
            self->_startDate = [[NSDate date] laterDate:startDate]; // Not earlier than now.
        }
        else {
            self->_startDate = [NSDate dateWithTimeIntervalSinceNow:interval]; // First fire after interval.
        }
        self->_interval = MAX(interval, 0); // Not less than zero.
        self->_leeway = MAX(leeway, 0); // Not less than zero.
        self->_endDate = [endDate laterDate:self->_startDate]; // Not earlier that startDate.
        
        [owner.decomposer addOwnedObject:self cleanup:^(__unsafe_unretained id owner) {
            if (self.timer) {
                [self stop];
            }
        }];
        
        [self start];
    }
    return self;
}


+ (instancetype)timerForDate:(NSDate *)fireDate {
    return [[self alloc] initWithOwner:nil queue:nil startDate:fireDate interval:0 leeway:0 endDate:nil];
}


+ (instancetype)timerWithInterval:(NSTimeInterval)seconds owner:(id)owner {
    return [[self alloc] initWithOwner:owner queue:nil startDate:nil interval:seconds leeway:0 endDate:nil];
}


+ (instancetype)timerWithInterval:(NSTimeInterval)seconds untilDate:(NSDate *)date {
    return [[self alloc] initWithOwner:nil queue:nil startDate:nil interval:seconds leeway:0 endDate:date];
}


+ (instancetype)backgroundTimerWithInterval:(NSTimeInterval)seconds owner:(id)owner {
    return [[self alloc] initWithOwner:owner queue:[OCAQueue background] startDate:nil interval:seconds leeway:0 endDate:nil];
}


+ (instancetype)backgroundTimerWithInterval:(NSTimeInterval)seconds untilDate:(NSDate *)date {
    return [[self alloc] initWithOwner:nil queue:[OCAQueue background] startDate:nil interval:seconds leeway:0 endDate:date];
}





#pragma mark Lifetime of Timer


- (void)start {
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.queue.dispatchQueue);
    
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW,
                                              self.startDate.timeIntervalSinceNow * NSEC_PER_SEC);
    
    dispatch_source_set_timer(self.timer,
                              startTime,
                              self.interval * NSEC_PER_SEC,
                              self.leeway * NSEC_PER_SEC);
    
    BOOL isNonRepeating = (self.interval <= 0);
    NSDate *endDate = self.endDate; // So we don't access the property multiple times in the block.
    __block NSUInteger fire = 1;
    __block NSDate *lastFireDate = [NSDate date];
    
    dispatch_source_set_event_handler(self.timer, ^{
        NSTimeInterval fireInterval = OCARound(-lastFireDate.timeIntervalSinceNow, self.interval);
        lastFireDate = [NSDate date];
        
        BOOL isAfterEndDate = (endDate && [endDate timeIntervalSinceNow] <= 0);
        if (isAfterEndDate) {
            // TODO: more precise endDate
            // Not producing value after endDate.
            [self stop];
            return;
        }
        
        if (isNonRepeating) {
            // One fire is enough.
            [self produceValue:@(fireInterval)];
            [self stop];
            return;
        }
        else {
            // Repeating timer.
            [self produceValue:@(fireInterval)];
            fire ++;
        }
    });
    
    dispatch_source_set_cancel_handler(self.timer, ^{
        [self finishProducingWithError:nil];
    });
    
    dispatch_resume(self.timer);
    self.isRunning = YES;
}


- (void)produceValue:(NSNumber *)value {
    [super produceValue:value];
    self.elapsedTime += value.doubleValue;
}


- (void)stop {
    if ( ! self.timer) return;
    
    dispatch_source_cancel(self.timer);
    self.timer = nil;
    self.isRunning = NO;
    [[self.owner decomposer] removeOwnedObject:self];
}


- (void)dealloc {
    [self stop];
}





#pragma mark Derived Producers


- (OCAProducer *)produceElapsedTime {
    return OCAProperty(self, elapsedTime, NSTimeInterval);
}


- (OCAProducer *)produceRemainingTime {
    OCABridge *bridge = [OCABridge bridgeWithTransformers:
                         [OCATransformer timeIntervalToDate:self.endDate],
                         [OCAMath minimumOf:0],
                         nil];
    [[self produceCurrentDate] connectTo:bridge];
    return bridge;
}


- (OCAProducer *)produceCurrentDate {
    OCABridge *bridge = [OCABridge bridgeWithTransformers:
                         [OCATransformer replaceWithCurrentDate],
                         nil];
    [self connectTo:bridge];
    [OCACommand send:[NSDate new] to:bridge];
    return bridge;
}





@end


