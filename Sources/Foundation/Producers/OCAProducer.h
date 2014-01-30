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


#pragma mark Describing Producer

- (NSString *)descriptionName;
- (NSDictionary *)debugDescriptionValues;


#pragma mark Covenience Methods

- (void)consumeBy:(id<OCAConsumer>)consumer CONVENIENCE;



@end
