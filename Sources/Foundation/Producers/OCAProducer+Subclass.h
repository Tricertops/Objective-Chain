//
//  OCAProducer+Subclass.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAProducer.h"





/*! Interface to be used by subclasses. Before you decide to subclass Producer, you may consider to use Command subclass.
 *  Every Producer must manage its own lifetime, so it should live and produce values until it makes sense. For example, a Timer produces values until the end date. Property produces until its observed object deallocates.
 *  To hook onto another object (a.k.a. owner), use Decomposer class.
 */
@interface OCAProducer ()



#pragma mark Creating Producer

//! Designated initializer. Your custom public initializer can provide a class that you are planning to produce. All produced values are validated to be of this class. May be nil, which means any values pass the validation.
- (instancetype)initWithValueClass:(Class)valueClass;


#pragma mark Managing Connections

//! Your subclass can provide a replacement for added consumer. Pass the original consumer or create Mediator, for example, to transform produced values.
- (id<OCAConsumer>)replacementConsumerForConsumer:(id<OCAConsumer>)consumer;

//! Empty. Called before the consumer is added, but after -replacementConsumerForConsumer: is called.
- (void)willAddConsumer:(id<OCAConsumer> )consumer;

//! If the receiver already finished, it calls -finishConsumingWithError: on the Consumer, otherwise it re-sends the latest produced value.
- (void)didAddConsumer:(id<OCAConsumer> )consumer;

//! Empty.
- (void)willRemoveConsumer:(id<OCAConsumer> )consumer;

//! Empty.
- (void)didRemoveConsumer:(id<OCAConsumer> )consumer;



#pragma mark Lifetime of Producer

//! Core method. Call this from your subclass with values you want to produce. Values are validated and sent to all Consumers. If the Producer already finished, nothing is sent.
- (void)produceValue:(id)value NS_REQUIRES_SUPER;

//! Core method. Call this from your subclass once you plan to send no more values. Marks the Producer as finished, sends the error to consumers and removes them. Usually after finishing, the Producer is no longer needed and may be deallocated. This method is automatically called before deallocation.
- (void)finishProducingWithError:(NSError *)error NS_REQUIRES_SUPER;

//! Readwrite acces to the laste produced value. You usually don't need to do any changes to it.
@property (atomic, readwrite, strong) id lastValue;

//! Called from -prodcuceValue:. Default implementation validated class of the value to the valueClass property. Override if you need other validation.
- (BOOL)validateProducedValue:(id)value;



#pragma mark Describing Producer

- (NSString *)descriptionName;
- (NSDictionary *)debugDescriptionValues;



@end


