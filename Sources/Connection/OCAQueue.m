//
//  OCAQueue.m
//  Objective-Chain
//
//  Created by Martin Kiss on 6.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAQueue.h"
#import "NSValue+Boxing.h"



static void * OCAQueueSpecificKey = &OCAQueueSpecificKey;





@interface OCAQueue ()


@property (nonatomic, readwrite, weak) OCAQueue *waitingForQueue;


@end










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
    if (isConcurrent && ! targetQueue.isConcurrent) NSLog(@"Objective-Chain: Warning: Couldn't create concurrent queue while targetting serial queue.");
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
        
        void *specific = (__bridge void *)self;
        [[self.class sharedQueueTable] setObject:self forKey:OCABox(specific)];
        dispatch_queue_set_specific(dispatchQueue, OCAQueueSpecificKey, specific, nil);
    }
    return self;
}





#pragma mark Getting Shared Queues


+ (instancetype)main {
    static OCAQueue *mainQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mainQueue = [[OCAQueue alloc] initWithDispatchQueue:dispatch_get_main_queue()];
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
        backgroundQueue->_name = @"Background";
        backgroundQueue->_isConcurrent = YES;
    });
    return backgroundQueue;
}


+ (NSMapTable *)sharedQueueTable {
    static NSMapTable *table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = [NSMapTable strongToWeakObjectsMapTable];
    });
    return table;
}





#pragma mark Accessing Current Queue


+ (instancetype)current {
    void *specific = dispatch_get_specific(OCAQueueSpecificKey);
    return  [[self sharedQueueTable] objectForKey:OCABox(specific)];
}





#pragma mark Adding Blocks to Queue


- (void)performBlock:(OCAQueueBlock)block {
    OCAAssert(block != nil, @"No block.") return;
    dispatch_async(self->_dispatchQueue, block);
}


- (void)performBlockAndWait:(OCAQueueBlock)block {
    OCAAssert(block != nil, @"No block.") return;
    
    OCAQueue *current = [OCAQueue current];
    OCAQueue *main = [OCAQueue main];
    
    BOOL isTargetedToMain = [self isTargetedTo:main];
    BOOL runningOnMain = [current isTargetedTo:main];
    BOOL mainToMain = (isTargetedToMain && runningOnMain);
    
    if (self == current || mainToMain || [self isWaitingFor:current]) {
        NSLog(@"Objective-Chain: Notice: Preventing deadlock in -[OCAQueue performBlockAndWait:] by invoking block directly.");
        block();
    }
    else {
        [current markWaitingFor:self];
        dispatch_sync(self->_dispatchQueue, block);
        [current markWaitingFor:nil];
    }
}


- (void)performBarrierBlock:(OCAQueueBlock)block {
    OCAAssert(block != nil, @"No block.") return;
    
    OCAAssert(self != [OCAQueue background], @"Cannot perform barriers directly on shared Background queue."){
        [self performBlock:block];
        return;
    }
    OCAAssert(self != [OCAQueue main], @"Cannot perform barriers directly on Main queue.") {
        [self performBlock:block];
        return;
    }
    
    dispatch_barrier_async(self->_dispatchQueue, block);
}


- (void)performBarrierBlockAndWait:(OCAQueueBlock)block {
    OCAAssert(block != nil, @"No block.") return;
    
    OCAAssert(self != [OCAQueue background], @"Cannot perform barriers directly on shared Background queue."){
        [self performBlockAndWait:block];
        return;
    }
    OCAAssert(self != [OCAQueue main], @"Cannot perform barriers directly on Main queue.") {
        [self performBlockAndWait:block];
        return;
    }
    
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


@synthesize waitingForQueue = _waitingForQueue;


- (OCAQueue *)waitingForQueue {
    return self->_waitingForQueue ?: self.targetQueue.waitingForQueue;
}


- (void)setWaitingForQueue:(OCAQueue *)waitingForQueue {
    self->_waitingForQueue = (self.isConcurrent? nil : waitingForQueue);
}


- (void)markWaitingFor:(OCAQueue *)waitedFor {
    OCAQueue *queue = self;
    while (queue) {
        if (queue.isConcurrent) break;
        queue.waitingForQueue = waitedFor;
        queue = queue.targetQueue;
    }
}


- (BOOL)isWaitingFor:(OCAQueue *)destinationQueue {
    OCAQueue *waitingFor = self;
    while (waitingFor) {
        if (waitingFor == destinationQueue) return YES;
        waitingFor = waitingFor.waitingForQueue;
    }
    return NO;
}





#pragma mark Describing Queue


- (NSString *)description {
    if (self == [OCAQueue main]) return @"Main Serial Queue";
    if (self == [OCAQueue background]) return @"Background Concurrent Queue";
    return [NSString stringWithFormat:@"%@ queue %@%@%@", (self->_isConcurrent? @"Concurrent" : @"Serial"), self->_name, (self.targetQueue? @" –> " : @""), self.targetQueue ?: @""];
}


- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@ %p; name = \"%@\"; isConcurrent = %@; targetQueue = %@>",
            self.class, self, self->_name, (self->_isConcurrent? @"YES" : @"NO"), self.targetQueue.debugDescription];
}






@end


