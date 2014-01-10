//
//  OCATimer.m
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCATimer.h"
#import "OCAProducer+Subclass.h"
#import "OCAQueue.h"





@interface OCATimer ()


@property (atomic, readwrite, strong) dispatch_source_t timer;


@end










@implementation OCATimer





#pragma mark Creating Timer


- (instancetype)init {
    return [self initWithTarget:nil delay:0 interval:0 leeway:0 untilDate:nil];
}


- (instancetype)initWithTarget:(OCAQueue *)targetQueue delay:(NSTimeInterval)delay interval:(NSTimeInterval)interval leeway:(NSTimeInterval)leeway untilDate:(NSDate *)date {
    self = [super initWithValueClass:[NSDate class]];
    if (self) {
        OCAAssert(delay >= 0, @"Works only with non-negative delay.") return nil;
        OCAAssert(interval > 0, @"Works only with positive intervals.") return nil;
        OCAAssert(leeway >= 0, @"Works only with non-negative leeway.") return nil;
        
        self->_queue = [[OCAQueue alloc] initWithName:@"Timer Queue" concurrent:NO targetQueue:targetQueue ?: [OCAQueue current]];
        
        self->_delay = delay;
        self->_interval = interval;
        self->_date = date;
        self->_leeway = leeway;
        
        [self start];
    }
    return self;
}


+ (instancetype)timerWithInterval:(NSTimeInterval)interval {
    return [[self alloc] initWithTarget:nil delay:0 interval:interval leeway:0 untilDate:nil];
}


+ (instancetype)timerWithInterval:(NSTimeInterval)interval until:(NSDate *)date {
    return [[self alloc] initWithTarget:nil delay:0 interval:interval leeway:0 untilDate:date];
}


+ (instancetype)backgroundTimerWithInterval:(NSTimeInterval)interval {
    return [[self alloc] initWithTarget:[OCAQueue background] delay:0 interval:interval leeway:0 untilDate:nil];
}


+ (instancetype)backgroundTimerWithInterval:(NSTimeInterval)interval until:(NSDate *)date {
    return [[self alloc] initWithTarget:[OCAQueue background] delay:0 interval:interval leeway:0 untilDate:date];
}





#pragma mark Lifetime of Timer


- (void)start {
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.queue.dispatchQueue);
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, self.delay * NSEC_PER_SEC);
    dispatch_source_set_timer(self.timer, startTime, self.interval * NSEC_PER_SEC, self.leeway * NSEC_PER_SEC);
    
    __block NSUInteger tick = 0;
    dispatch_source_set_event_handler(self.timer, ^{
        if (self.date.timeIntervalSinceNow < 0) {
            [self stop];
            return;
        }
        
        [self produceValue:[NSDate date]];
    });
    
    dispatch_source_set_cancel_handler(self.timer, ^{
        [self finishProducingWithError:nil];
    });
    
    dispatch_resume(self.timer);
}


- (void)stop {
    dispatch_source_cancel(self.timer);
    self.timer = nil;
}





#pragma mark Describing Timer


- (NSString *)descriptionName {
    return @"Timer";
}


- (NSString *)description {
    NSString *adjective = (self.finished? @"Finished " : @"");
    NSString *d = [NSString stringWithFormat:@"%@%@ at %@s on %@", adjective, self.shortDescription, @(self.interval), self.queue.shortDescription];
    if (self.date) {
        d = [d stringByAppendingFormat:@" until %@", self.date];
    }
    return d;
    // Timer (0x0) for 0.1s
    // Finished Timer (0x0) for 0.05s until 2014-01-09 13:11:13+0200
}


- (NSDictionary *)debugDescriptionValues {
    return @{
             @"delay": @(self.delay),
             @"interval": @(self.interval),
             @"leeway": @(self.leeway),
             @"date": self.date,
             @"connections": @(self.connections.count),
             };
}





@end


