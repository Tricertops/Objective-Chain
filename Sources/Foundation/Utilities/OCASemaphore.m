//
//  OCASemaphore.m
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCASemaphore.h"



@interface OCASemaphore ()

@property (atomic, readonly, strong) dispatch_semaphore_t semaphore;

@end





@implementation OCASemaphore





#pragma mark Creating Semaphore


- (instancetype)init {
    return [self initWithValue:0];
}


- (instancetype)initWithValue:(NSUInteger)integer {
    self = [super init];
    if (self) {
        self->_semaphore = dispatch_semaphore_create(integer);
    }
    return self;
}





#pragma mark Using Semaphore


- (void)signal {
    dispatch_semaphore_signal(self.semaphore);
}


- (void)wait {
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}


- (BOOL)waitFor:(NSTimeInterval)interval {
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC);
    long timedOut = dispatch_semaphore_wait(self.semaphore, time);
    return ! timedOut;
}


- (BOOL)waitUntil:(NSDate *)date {
    return [self waitFor:date.timeIntervalSinceNow];
}





@end
