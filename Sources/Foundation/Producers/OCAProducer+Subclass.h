//
//  OCAProducer+Subclass.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAProducer.h"





/// Methods used internally by other classes.
@interface OCAProducer ()


#pragma mark Creating Producer

- (instancetype)initWithValueClass:(Class)valueClass;


#pragma mark Managing Connections

- (id<OCAConsumer>)replacementConsumerForConsumer:(id<OCAConsumer>)consumer;
- (void)willAddConsumer:(id<OCAConsumer> )consumer;
- (void)didAddConsumer:(id<OCAConsumer> )consumer;

- (void)willRemoveConsumer:(id<OCAConsumer> )consumer;
- (void)didRemoveConsumer:(id<OCAConsumer> )consumer;


#pragma mark Lifetime of Producer

@property (atomic, readwrite, strong) id lastValue;

- (BOOL)validateProducedValue:(id)value;
- (void)produceValue:(id)value NS_REQUIRES_SUPER;
- (void)finishProducingWithError:(NSError *)error NS_REQUIRES_SUPER;




@end
