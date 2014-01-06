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


- (instancetype)initWithName:(NSString *)name concurrent:(BOOL)isConcurrent targetQueue:(OCAQueue *)targetQueue {
    dispatch_queue_t dispatchQueue = dispatch_queue_create(name.UTF8String, (isConcurrent? DISPATCH_QUEUE_CONCURRENT : DISPATCH_QUEUE_SERIAL));
    OCAQueue *realTargetQueue = targetQueue ?: [OCAQueue background];
    dispatch_set_target_queue(dispatchQueue, realTargetQueue.dispatchQueue);
    self = [self initWithDispatchQueue:dispatchQueue];
    if (self) {
        self->_targetQueue = realTargetQueue;
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


+ (instancetype)main {
    static OCAQueue *mainQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mainQueue = [[OCAQueue alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    });
    return mainQueue;
}


+ (instancetype)background {
    static OCAQueue *backgroundQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        backgroundQueue = [[OCAQueue alloc] initWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    });
    return backgroundQueue;
}





#pragma mark Working with Queues


- (void)performBlock:(OCAQueueBlock)block {
    OCAAssert(block != nil, @"No block.") return;
    dispatch_async(self->_dispatchQueue, block);
}


- (void)performBlockAndWait:(OCAQueueBlock)block {
    OCAAssert(block != nil, @"No block.") return;
    //TODO: Check for deadlock.
    dispatch_sync(self->_dispatchQueue, block);
}


- (void)performBarrierBlock:(OCAQueueBlock)block {
    OCAAssert(block != nil, @"No block.") return;
    dispatch_barrier_async(self->_dispatchQueue, block);
}


- (void)performBarrierBlockAndWait:(OCAQueueBlock)block {
    OCAAssert(block != nil, @"No block.") return;
    dispatch_barrier_sync(self->_dispatchQueue, block);
}


- (void)performAfter:(NSTimeInterval)delay block:(OCAQueueBlock)block {
    OCAAssert(block != nil, @"No block.") return;
    OCAAssert(delay >= 0, @"Negative delay? Oh, come on!") delay = 0;
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (delay * NSEC_PER_SEC));
    dispatch_after(time, self->_dispatchQueue, block);
}






@end


