//
//  OCATimer.m
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//
//

#import "OCATimer.h"
#import "OCAProducer+Private.h"










@implementation OCATimer





#pragma mark Creating Timer


- (instancetype)initWithDelay:(NSTimeInterval)delay interval:(NSTimeInterval)interval leeway:(NSTimeInterval)leeway count:(NSUInteger)count {
    self = [super init];
    if (self) {
        OCAAssert(delay >= 0, @"Works only with non-negative delay.") return nil;
        OCAAssert(interval > 0, @"Works only with positive intervals.") return nil;
        OCAAssert(leeway >= 0, @"Works only with non-negative leeway.") return nil;
        
        self->_delay = delay;
        self->_interval = interval;
        self->_count = count ?: NSUIntegerMax;
        self->_leeway = leeway;
        
        __block NSUInteger tick = 0;
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
        dispatch_source_set_timer(timer, startTime, interval * NSEC_PER_SEC, leeway * NSEC_PER_SEC);
        
        dispatch_source_set_event_handler(timer, ^{
            tick ++;
            
            NSDate *date = [NSDate date];
            [self sendValue:date];
            
            if (tick >= count) {
                dispatch_source_cancel(timer);
                [self finishWithError:nil];
            }
        });
        
        dispatch_resume(timer);
    }
    return self;
}





@end


