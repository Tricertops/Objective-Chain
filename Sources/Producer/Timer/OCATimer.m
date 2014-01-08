//
//  OCATimer.m
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCATimer.h"
#import "OCAProducer+Private.h"
#import "OCAQueue.h"










@implementation OCATimer





#pragma mark Creating Timer


- (instancetype)init {
    return [self initWithTarget:nil delay:0 interval:0 leeway:0 count:0];
}


- (instancetype)initWithTarget:(OCAQueue *)targetQueue delay:(NSTimeInterval)delay interval:(NSTimeInterval)interval leeway:(NSTimeInterval)leeway count:(NSUInteger)count {
    self = [super initWithValueClass:[NSDate class]];
    if (self) {
        OCAAssert(delay >= 0, @"Works only with non-negative delay.") return nil;
        OCAAssert(interval > 0, @"Works only with positive intervals.") return nil;
        OCAAssert(leeway >= 0, @"Works only with non-negative leeway.") return nil;
        
        self->_queue = [[OCAQueue alloc] initWithName:@"Timer Queue" concurrent:NO targetQueue:targetQueue ?: [OCAQueue current]];
        
        self->_delay = delay;
        self->_interval = interval;
        self->_count = count ?: NSUIntegerMax;
        self->_leeway = leeway;
        
        [self start];
    }
    return self;
}


+ (instancetype)timerWithInterval:(NSTimeInterval)interval {
    return [[self alloc] initWithTarget:nil delay:0 interval:interval leeway:0 count:0];
}


+ (instancetype)timerWithInterval:(NSTimeInterval)interval count:(NSUInteger)count {
    return [[self alloc] initWithTarget:nil delay:0 interval:interval leeway:0 count:count];
}


+ (instancetype)backgroundTimerWithInterval:(NSTimeInterval)interval {
    return [[self alloc] initWithTarget:[OCAQueue background] delay:0 interval:interval leeway:0 count:0];
}


+ (instancetype)backgroundTimerWithInterval:(NSTimeInterval)interval count:(NSUInteger)count {
    return [[self alloc] initWithTarget:[OCAQueue background] delay:0 interval:interval leeway:0 count:count];
}





#pragma mark Lifetime of Timer


- (void)start {
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.queue.dispatchQueue);
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, self.delay * NSEC_PER_SEC);
    dispatch_source_set_timer(timer, startTime, self.interval * NSEC_PER_SEC, self.leeway * NSEC_PER_SEC);
    
    NSUInteger count = self.count;
    __block NSUInteger tick = 0;
    dispatch_source_set_event_handler(timer, ^{
        tick ++;
        NSLog(@"Tick %lu", (unsigned long)tick);
        NSDate *date = [NSDate date];
        [self produceValue:date];
        
        if (tick >= count) {
            dispatch_source_cancel(timer);
            NSLog(@"Finished");
            [self finishProducingWithError:nil];
        }
    });
    
    dispatch_resume(timer);
}





#pragma mark Describing Timer


- (NSString *)descriptionName {
    return @"Timer";
}


- (NSString *)description {
    NSString *adjective = (self.finished? @"Finished " : @"");
    NSString *d = [NSString stringWithFormat:@"%@%@ at %@s on %@", adjective, self.shortDescription, @(self.interval), self.queue.shortDescription];
    if (self.count == NSUIntegerMax) {
        d = [d stringByAppendingFormat:@" with %@ ticks", @(self.count)];
    }
    return d;
    // Timer (0x0) for 0.1s
    // Finished Timer (0x0) for 0.05s with 100 ticks
}


- (NSDictionary *)debugDescriptionValues {
    return @{
             @"delay": @(self.delay),
             @"interval": @(self.interval),
             @"leeway": @(self.leeway),
             @"count": @(self.count),
             @"connections": @(self.connections.count),
             };
}





@end


