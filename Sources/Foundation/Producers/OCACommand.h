//
//  OCACommand.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAProducer.h"





//! Command is a Producer that allows manually sending values. Using Command is an alternative to subclassing the Producer.
@interface OCACommand : OCAProducer



#pragma mark Creating Command

//! Initializes Command that produces values of given class.
- (instancetype)initWithValueClass:(Class)valueClass;

//! Creates Command that produces values of given class.
+ (instancetype)commandForClass:(Class)valueClass;

//! Shortcut to manually send value to any consumer. Creates temporary Command producer.
+ (void)send:(id)value to:(id<OCAConsumer>)consumer;



#pragma mark Using Command

//! Produces value to all Consumers.
- (void)sendValue:(id)value;

//! Produces values in array to all Consumers.
- (void)sendValues:(NSArray *)values;

//! Marks the Command as finished and sends the errro to Consumers.
- (void)finishWithError:(NSError *)error;



@end


