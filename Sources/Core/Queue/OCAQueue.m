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
    
    NSString *label = [NSString stringWithFormat:@"com.ObjectiveChain.queue.%@", [name stringByReplacingOccurrencesOfString:@" " withString:@""]];
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


+ (instancetype)serialQueue:(NSString *)name {
    return [[self alloc] initWithName:name concurrent:NO targetQueue:nil];
}

+ (instancetype)concurrentQueue:(NSString *)name {
    return [[self alloc] initWithName:name concurrent:YES targetQueue:nil];
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


- (BOOL)shouldInvokeSynchronousBlocksDirectlyToAvoidDeadlock {
    OCAQueue *current = [OCAQueue current];
    if (self == current) return YES; // Definitely deadlocking!
    
    //TODO: Targetting to Main may have separate property.
    BOOL isTargetedToMain = [self isTargetedTo:[OCAQueue main]];
    BOOL runningOnMain = [current isTargetedTo:[OCAQueue main]];
    // If both Current and Self are targetted to Main, it would deadlock!
    return (isTargetedToMain && runningOnMain);
}





#pragma mark Adding Blocks to Queue


- (void)performBlock:(OCAQueueBlock)block {
    OCAAssert(block != nil, @"No block.") return;
    dispatch_async(self.dispatchQueue, block);
}


- (void)performBlockAndWait:(OCAQueueBlock)block {
    OCAAssert(block != nil, @"No block.") return;
    
    if ([self shouldInvokeSynchronousBlocksDirectlyToAvoidDeadlock]) {
        NSLog(@"Objective-Chain: Notice: Preventing deadlock in -[OCAQueue performBlockAndWait:] by invoking block directly.");
        block();
    }
    else {
        dispatch_sync(self.dispatchQueue, block);
    }
}


- (void)performBlockAndTryWait:(OCAQueueBlock)block {
    OCAAssert(block != nil, @"No block.") return;
    
    if ([self shouldInvokeSynchronousBlocksDirectlyToAvoidDeadlock]) {
        block(); // No thread hop, preserve stack trace.
    }
    else {
        // Asynchronous invocation when we are not on the same thread.
        dispatch_async(self.dispatchQueue, block);
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
    
    dispatch_barrier_async(self.dispatchQueue, block);
}


- (void)performBarrierBlockAndWait:(OCAQueueBlock)block {
    OCAAssert(block != nil, @"No block.") return;
    
    OCAQueue *current = [OCAQueue current];
    OCAQueue *main = [OCAQueue main];
    
    OCAAssert(self != [OCAQueue background], @"Cannot perform barriers directly on shared Background queue."){
        [self performBlockAndWait:block];
        return;
    }
    OCAAssert(self != main, @"Cannot perform barriers directly on Main queue.") {
        [self performBlockAndWait:block];
        return;
    }
    
    BOOL isTargetedToMain = [self isTargetedTo:main];
    BOOL runningOnMain = [current isTargetedTo:main];
    BOOL mainToMain = (isTargetedToMain && runningOnMain);
    
    if (self == current || mainToMain) {
        NSLog(@"Objective-Chain: Notice: Preventing deadlock in -[OCAQueue performBarrierBlockAndWait:] by invoking block directly.");
        block();
    }
    else {
        dispatch_barrier_sync(self.dispatchQueue, block);
    }
}


- (void)performAfter:(NSTimeInterval)delay block:(OCAQueueBlock)block {
    OCAAssert(block != nil, @"No block.") return;
    OCAAssert(delay >= 0, @"Negative delay? Oh, come on!") delay = 0;
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (delay * NSEC_PER_SEC));
    dispatch_after(time, self.dispatchQueue, block);
}


- (void)performMultiple:(NSUInteger)count blocks:(void(^)(NSUInteger i))block {
    OCAAssert(block != nil, @"No block.") return;
    
    dispatch_apply(count, self.dispatchQueue, (void(^)(size_t))block);
}





#pragma mark Accessing Target Queue



- (BOOL)isTargetedTo:(OCAQueue *)targetQueue {
    // Traverse target relationship.
    OCAQueue *queue = self;
    while (queue) {
        if (queue == targetQueue) return YES;
        queue = queue.targetQueue;
    }
    return NO;
}





#pragma mark Describing Queue


- (NSString *)descriptionName {
    if (self == [OCAQueue main]) return @"Main Queue";
    if (self == [OCAQueue background]) return @"Background Queue";
    return self.name;
}


- (NSString *)description {
    NSString *adjective = (self.isConcurrent? @"Concurrent" : @"Serial");
    NSString *d = [NSString stringWithFormat:@"%@ %@", adjective, self.shortDescription];
    if (self.targetQueue) {
        d = [d stringByAppendingFormat:@" targeted to %@", self.targetQueue.shortDescription];
    }
    return d;
    // Serial Main Queue (0x0)
    // Concurrent Loading Queue (0x0) targeted to Background Queue (0x0)
}


- (NSDictionary *)debugDescriptionValues {
    return @{
             @"name": self.name,
             @"concurrent": (self.isConcurrent? @"YES" : @"NO"),
             @"target": self.targetQueue.debugShortDescription,
             };
}






@end


