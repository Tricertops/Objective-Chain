//
//  OCAQueue.m
//  Objective-Chain
//
//  Created by Martin Kiss on 6.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAQueue.h"










@implementation OCAQueue





#pragma mark Creating Queues


+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self main];
        [self background];
    });
}


- (instancetype)initWithName:(NSString *)name concurrent:(BOOL)isConcurrent targetQueue:(OCAQueue *)targetQueue {
    targetQueue = targetQueue ?: [OCAQueue background];
    isConcurrent = (isConcurrent && targetQueue.isConcurrent);
    
    NSString *label = [NSString stringWithFormat:@"com.ObjectiveChain.queue.%@", name];
    dispatch_queue_t dispatchQueue = dispatch_queue_create(label.UTF8String, (isConcurrent? DISPATCH_QUEUE_CONCURRENT : DISPATCH_QUEUE_SERIAL));
    dispatch_set_target_queue(dispatchQueue, targetQueue.dispatchQueue);
    
    self = [self initWithDispatchQueue:dispatchQueue];
    if (self) {
        self->_name = [name copy];
        self->_isConcurrent = isConcurrent;
        self->_targetQueue = targetQueue;
    }
    return self;
}


- (instancetype)initWithDispatchQueue:(dispatch_queue_t)dispatchQueue {
    self = [super init];
    if (self) {
        OCAAssert(dispatchQueue != nil, @"Need a dispatch_queue_t!") return nil;
        self->_dispatchQueue = dispatchQueue;
    }
    return self;
}





#pragma mark Getting Shared Queues


static void * OCAQueueSpecificKey = &OCAQueueSpecificKey;
static void * OCAQueueSpecificMain = &OCAQueueSpecificMain;
static void * OCAQueueSpecificBackground = &OCAQueueSpecificBackground;


+ (instancetype)main {
    static OCAQueue *mainQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mainQueue = [[OCAQueue alloc] initWithDispatchQueue:dispatch_get_main_queue()];
        dispatch_queue_set_specific(mainQueue.dispatchQueue, OCAQueueSpecificKey, OCAQueueSpecificMain, nil);
        mainQueue->_name = @"Main";
        mainQueue->_isConcurrent = NO;
    });
    return mainQueue;
}


+ (instancetype)background {
    static OCAQueue *backgroundQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        backgroundQueue = [[OCAQueue alloc] initWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        dispatch_queue_set_specific(backgroundQueue.dispatchQueue, OCAQueueSpecificKey, OCAQueueSpecificBackground, nil);
        backgroundQueue->_name = @"Background";
        backgroundQueue->_isConcurrent = YES;
    });
    return backgroundQueue;
}





#pragma mark Accessing Current Queue

+ (instancetype)current {
    void *context = dispatch_get_specific(OCAQueueSpecificKey);
    if (context == OCAQueueSpecificMain) {
        return [OCAQueue main];
    }
    else if (context == OCAQueueSpecificBackground) {
        return [OCAQueue background];
    }
    return nil;
}





#pragma mark Working with Queues


- (void)performBlock:(OCAQueueBlock)block {
    OCAAssert(block != nil, @"No block.") return;
    dispatch_async(self->_dispatchQueue, block);
}


- (void)performBlockAndWait:(OCAQueueBlock)block {
    OCAAssert(block != nil, @"No block.") return;
    
    //TODO: Handle deadlocks.
    dispatch_sync(self->_dispatchQueue, block);
}


- (void)performBarrierBlock:(OCAQueueBlock)block {
    OCAAssert(block != nil, @"No block.") return;
    dispatch_barrier_async(self->_dispatchQueue, block);
}


- (void)performBarrierBlockAndWait:(OCAQueueBlock)block {
    OCAAssert(block != nil, @"No block.") return;
    
    //TODO: Handle deadlocks.
    dispatch_barrier_sync(self->_dispatchQueue, block);
}


- (void)performAfter:(NSTimeInterval)delay block:(OCAQueueBlock)block {
    OCAAssert(block != nil, @"No block.") return;
    OCAAssert(delay >= 0, @"Negative delay? Oh, come on!") delay = 0;
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (delay * NSEC_PER_SEC));
    dispatch_after(time, self->_dispatchQueue, block);
}





#pragma mark Accessing Target Queue



- (BOOL)isTargetedTo:(OCAQueue *)targetQueue {
    OCAQueue *queue = self;
    while (queue) {
        if (queue == targetQueue) return YES;
        queue = queue.targetQueue;
    }
    return NO;
}





#pragma mark Describing Queue


- (NSString *)description {
    return [NSString stringWithFormat:@"%@ queue %@%@%@", (self->_isConcurrent? @"Concurrent" : @"Serial"), self->_name, (self.targetQueue? @" –> " : @""), self.targetQueue ?: @""];
}


- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@ %p; name = %@; isConcurrent = %@; targetQueue = %@>",
            self.class, self, self->_name, (self->_isConcurrent? @"YES" : @"NO"), self.targetQueue.debugDescription];
}






@end


