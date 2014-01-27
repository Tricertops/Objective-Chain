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





@interface OCATimer ()


@property (atomic, readwrite, strong) dispatch_source_t timer;
@property (atomic, readwrite, assign) BOOL isRunning;


@end










@implementation OCATimer





#pragma mark Creating Timer


- (instancetype)init {
    return [self initWithOwner:nil queue:nil startDate:nil interval:0 leeway:0 endDate:nil];
}


- (instancetype)initWithOwner:(NSObject *)owner queue:(OCAQueue *)targetQueue startDate:(NSDate *)startDate interval:(NSTimeInterval)interval leeway:(NSTimeInterval)leeway endDate:(NSDate *)endDate {
    self = [super initWithValueClass:[NSDate class]];
    if (self) {
        OCAAssert(interval > 0, @"Works only with positive intervals.") return nil;
        OCAAssert(leeway >= 0, @"Works only with non-negative leeway.") return nil;
        
        self->_owner = owner;
        self->_queue = [[OCAQueue alloc] initWithName:@"Timer Queue" concurrent:NO targetQueue:targetQueue ?: [OCAQueue background]];
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
                NSLog(@"%@: Owner deallocated", self.shortDescription);
                [self stop];
            }
        }];
        
        [self start];
    }
    return self;
}


+ (instancetype)fireAt:(NSDate *)fireDate {
    return [[self alloc] initWithOwner:nil queue:nil startDate:fireDate interval:0 leeway:0 endDate:nil];
}


+ (instancetype)repeat:(NSTimeInterval)seconds owner:(id)owner {
    return [[self alloc] initWithOwner:owner queue:nil startDate:nil interval:seconds leeway:0 endDate:nil];
}


+ (instancetype)repeat:(NSTimeInterval)seconds until:(NSDate *)date {
    return [[self alloc] initWithOwner:nil queue:nil startDate:nil interval:seconds leeway:0 endDate:date];
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
    
    dispatch_source_set_event_handler(self.timer, ^{
        
        BOOL isAfterEndDate = (endDate && [endDate timeIntervalSinceNow] <= 0);
        if (isAfterEndDate) {
            // Not producing value after endDate.
            NSLog(@"%@: Reached end date", self.shortDescription);
            [self stop];
            return;
        }
        
        if (isNonRepeating) {
            // One fire is enough.
            NSLog(@"%@: Single fire", self.shortDescription);
            [self produceValue:[NSDate date]];
            [self stop];
            return;
        }
        else {
            // Repeating timer.
            [self produceValue:[NSDate date]];
            fire ++;
        }
    });
    
    dispatch_source_set_cancel_handler(self.timer, ^{
        [self finishProducingWithError:nil];
    });
    
    NSLog(@"%@: Started", self.shortDescription);
    dispatch_resume(self.timer);
    self.isRunning = YES;
}


- (void)stop {
    if ( ! self.timer) return;
    
    NSLog(@"%@: Stopped", self.shortDescription);
    dispatch_source_cancel(self.timer);
    self.timer = nil;
    self.isRunning = NO;
    [[self.owner decomposer] removeOwnedObject:self];
}


- (void)dealloc {
    NSLog(@"%@: Deallocated", self.shortDescription);
}





#pragma mark Describing Timer


- (NSString *)descriptionName {
    return @"Timer";
}


- (NSString *)description {
    NSMutableString *d = [[NSMutableString alloc] init];
    if (self.finished) {
        [d appendString:@"Finished "];
    }
    [d appendString:self.shortDescription];
    BOOL isRepeating = (self.interval > 0);
    if ( ! isRepeating) {
        [d appendFormat:@" at %@", self.startDate];
    }
    if (isRepeating) {
        [d appendFormat:@" for %@s", @(self.interval)];
    }
    if (self.endDate) {
        [d appendFormat:@" until %@", self.endDate];
    }
    [d appendFormat:@" on %@", self.queue.shortDescription];
    return d;
}


- (NSDictionary *)debugDescriptionValues {
    return @{
             @"owner": self.owner ?: @"nil",
             @"queue": self.queue ?: @"nil",
             @"startDate": self.startDate ?: @"nil",
             @"interval": @(self.interval),
             @"leeway": @(self.leeway),
             @"endDate": self.endDate ?: @"nil",
             @"finished": (self.finished? @"YES":@"NO"),
             @"connections": @(self.consumers.count),
             };
}





@end


