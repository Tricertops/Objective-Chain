//
//  OCAQueue.h
//  Objective-Chain
//
//  Created by Martin Kiss on 6.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAObject.h"



typedef void (^OCAQueueBlock)(void);





@interface OCAQueue : OCAObject



#pragma mark Getting Shared Queues

+ (instancetype)main;
+ (instancetype)background;


#pragma mark Accessing Current Queue

+ (instancetype)current;


#pragma mark Creating Queues

- (instancetype)initWithName:(NSString *)name concurrent:(BOOL)isConcurrent targetQueue:(OCAQueue *)targetQueue;


#pragma mark Attributes of Queue

@property (OCA_atomic, readonly, copy) NSString *name;
@property (OCA_atomic, readonly, assign) BOOL isConcurrent;
@property (OCA_atomic, readonly, strong) dispatch_queue_t dispatchQueue;

@property (OCA_atomic, readonly, assign) BOOL isWaiting;


#pragma mark Adding Blocks to Queue

- (void)performBlock:(OCAQueueBlock)block;
- (void)performBlockAndWait:(OCAQueueBlock)block;
- (void)performBarrierBlock:(OCAQueueBlock)block;
- (void)performBarrierBlockAndWait:(OCAQueueBlock)block;
- (void)performAfter:(NSTimeInterval)delay block:(OCAQueueBlock)block;


#pragma mark Accessing Target Queue

@property (OCA_atomic, readonly, strong) OCAQueue *targetQueue;
- (BOOL)isTargetedTo:(OCAQueue *)queue;



@end


