//
//  OCAProducer.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAObject.h"
#import "OCAConsumer.h"





/// Producer is abstract source of values that are sent to Connections.
@interface OCAProducer : OCAObject



#pragma mark Getting State of Producer

@property (atomic, readonly, strong) Class valueClass;

@property (atomic, readonly, strong) id lastValue;
@property (atomic, readonly, assign) BOOL finished;
@property (atomic, readonly, strong) NSError *error;


#pragma mark Inspecting Connections of Producer

@property (atomic, readonly, strong) NSArray *consumers;
- (void)addConsumer:(id<OCAConsumer> )consumer;
- (void)removeConsumer:(id<OCAConsumer> )consumer;
- (void)removeAllConsumers;



@end





/*! List of convenience methods of Producer, that allows you to create complex chains in-line.
 *  Many of them return conrcrete Producer subclasses so you can immediately call another chaining method on them.
 */
@interface OCAProducer (Chaining)



- (void)connectTo:(id<OCAConsumer>)consumer;

- (OCAHub *)mergeWith:(OCAProducer *)producer, ... NS_REQUIRES_NIL_TERMINATION;
- (OCAHub *)combineWith:(OCAProducer *)producer, ... NS_REQUIRES_NIL_TERMINATION;
//TODO: - (OCAHub *)dependOn:(OCAProducer *)producer, ... NS_REQUIRES_NIL_TERMINATION;



@end




