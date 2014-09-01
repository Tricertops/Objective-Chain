//
//  OCAProducer.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAObject.h"
#import "OCAConsumer.h"





/*! Producer is abstract class that produces values for Consumers.
 *  Concrete implementations include Timer, Notificator, Property, Command and custom subclasses can be implemented as well.
 *  It is responsibility of each Producer to manage its lifetime, so there is usually no need to retain it.
 *  Usually, you only need to create the Producer and use the Chaining methods listed below.
 */
@interface OCAProducer : OCAObject



#pragma mark State of the Producer

//! Class of the values produced by the receiver.
@property (atomic, readonly, strong) Class valueClass;

//! Value that was last produced by the receiver.
@property (atomic, readonly, strong) id lastValue;

//! Flag whether the receiver finished producing values. Once the Producer finishes, it al Consumers are informed about it.
@property (atomic, readonly, assign) BOOL isFinished;

//! If the receiver is finished, contains error that caused the producer to finish, or nil of there was none.
@property (atomic, readonly, strong) NSError *error;



#pragma mark Managing Consumers

//! A list of all Consumers of the receiver, so any values produced are passed to them. Consumers are retained.
@property (atomic, readonly, strong) NSArray *consumers;

//! Add the Consumer object into the list and the Consumer will receive all following values until removed.
- (void)addConsumer:(id<OCAConsumer> )consumer;

//! Remove the Consumer object into the list so it no longer receives new values from this Producer.
- (void)removeConsumer:(id<OCAConsumer> )consumer;

//! Remove all Consumers from the list.
- (void)removeAllConsumers;



@end





@class OCAHub;
@class OCAMediator;
@class OCABridge;
@class OCAContext;
@class OCAQueue;
@class OCAFilter;
@class OCAThrottle;
@class OCAInvoker;



/*! List of convenience methods of Producer, that allows you to create complex chains in-line.
 *  Many of them return conrcrete Producer subclasses so you can immediately call another chaining method on them.
 */
@interface OCAProducer (Chaining)



- (void)connectTo:(id<OCAConsumer>)consumer;
- (void)connectWeaklyTo:(id<OCAConsumer>)consumer;
- (void)connectToMany:(id<OCAConsumer>)consumer, ... NS_REQUIRES_NIL_TERMINATION;
- (OCAMediator *)chainTo:(OCAMediator *)mediator;

- (OCAHub *)mergeWith:(OCAProducer *)producer, ... NS_REQUIRES_NIL_TERMINATION;
- (OCAHub *)combineWith:(OCAProducer *)producer, ... NS_REQUIRES_NIL_TERMINATION;
- (OCAHub *)dependOn:(OCAProducer *)producer, ... NS_REQUIRES_NIL_TERMINATION;

- (OCABridge *)transformValues:(NSValueTransformer *)transformer, ... NS_REQUIRES_NIL_TERMINATION;
- (OCABridge *)replaceValuesWith:(id)replacement;
- (OCABridge *)replaceNilWith:(id)replacement;
- (OCABridge *)negateBoolean;

- (OCAContext *)produceInContext:(OCAContext *)context;
- (OCAContext *)switchToQueue:(OCAQueue *)queue;

- (OCAFilter *)filterValues:(NSPredicate *)predicate;
- (OCAFilter *)skipNil;
- (OCAFilter *)skipFirst:(NSUInteger)count;
- (OCAFilter *)skipEqual;

- (OCAThrottle *)throttle:(NSTimeInterval)interval;
- (OCAThrottle *)throttleContinuous:(NSTimeInterval)interval;

- (void)subscribe:(void(^)(void))handler;
- (void)subscribeForClass:(Class)theClass handler:(void(^)(id value))handler;
- (void)subscribeForClass:(Class)theClass handler:(void(^)(id value))handler finish:(void(^)(NSError *error))handler;

- (void)invoke:(OCAInvoker *)invoker;

- (void)switchIf:(NSPredicate *)predicate then:(id<OCAConsumer>)consumer else:(id<OCAConsumer>)consumer;
- (void)switchYes:(id<OCAConsumer>)consumer no:(id<OCAConsumer>)consumer;



@end




