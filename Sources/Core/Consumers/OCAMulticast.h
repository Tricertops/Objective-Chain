//
//  OCAMulticast.h
//  Objective-Chain
//
//  Created by Martin Kiss on 6.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAObject.h"
#import "OCAConsumer.h"
#import "OCAProducer.h"





/// Multicast is a Consumer, that forwards values to other Consumers based on their accepting class.
@interface OCAMulticast : OCAObject < OCAConsumer >



#pragma mark Creating Multicast

- (instancetype)initWithConsumers:(NSArray *)consumers;
+ (instancetype)multicast:(NSArray *)consumers;


#pragma mark Accessing Consumers of Multicast

@property (atomic, readonly, copy) NSArray *consumers;



@end





@interface OCAProducer (OCAMulticast)


- (OCAConnection *)multicast:(id<OCAConsumer>)consumer, ... NS_REQUIRES_NIL_TERMINATION;


@end


