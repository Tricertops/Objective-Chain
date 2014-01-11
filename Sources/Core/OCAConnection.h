//
//  OCAConnection.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAObject.h"

@class OCAProducer;
@class OCAQueue;
@protocol OCAConsumer;





/// Connection represents a data flow from a Provider to Consumer with customizable behavior.
@interface OCAConnection : OCAObject



#pragma mark Creating Connection

- (instancetype)initWithProducer:(OCAProducer *)producer
                           queue:(OCAQueue *)queue
                          filter:(NSPredicate *)predicate
                       transform:(NSValueTransformer *)transformer
                        consumer:(id<OCAConsumer>)consumer;


#pragma mark Endpoints of Connection

@property (atomic, readonly, weak) OCAProducer *producer;
@property (atomic, readonly, strong) id<OCAConsumer> consumer;


#pragma mark Controlling Connection

@property (atomic, readwrite, assign) BOOL enabled;

@property (atomic, readonly, strong) OCAQueue *queue;
@property (atomic, readonly, strong) NSPredicate *filter;
@property (atomic, readonly, strong) NSValueTransformer *transformer;

@property (atomic, readonly, assign) BOOL closed;
- (void)close;


#pragma mark Describing Connection

@property (atomic, readwrite, copy) NSString *name;
- (instancetype)describe:(NSString *)format, ... NS_REQUIRES_NIL_TERMINATION;



@end
