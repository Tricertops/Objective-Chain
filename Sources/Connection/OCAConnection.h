//
//  OCAConnection.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAObject.h"

@class OCAProducer;
@protocol OCAConsumer;





/// Connection represents a data flow from a Provider to Consumer with customizable behavior.
@interface OCAConnection : OCAObject



#pragma mark Creating Conenction

- (instancetype)initWithProducer:(OCAProducer *)producer
                          filter:(NSPredicate *)predicate
                       transform:(NSValueTransformer *)transformer
                        consumer:(id<OCAConsumer>)consumer;


#pragma mark Endpoints of Connection

@property (OCA_atomic, readonly, weak) OCAProducer *producer;
@property (OCA_atomic, readonly, strong) id<OCAConsumer> consumer;


#pragma mark Controlling Connection

@property (OCA_atomic, readwrite, assign) BOOL enabled; //TODO: Remotely check for enabled?
@property (OCA_atomic, readwrite, strong) NSPredicate *filter;
@property (OCA_atomic, readwrite, strong) NSValueTransformer *transformer;

@property (OCA_atomic, readonly, assign) BOOL closed;
- (void)close;


//TODO: Queues
//TODO: Behavior





@end
