//
//  OCAMulticast.h
//  Objective-Chain
//
//  Created by Martin Kiss on 6.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAObject.h"
#import "OCAConsumer.h"





/// Multicast is a Consumer, that forwards values to other Consumers based on their accepting class.
@interface OCAMulticast : OCAObject < OCAConsumer >



#pragma mark Creating Multicast

- (instancetype)initWithConsumers:(NSArray *)consumers;


#pragma mark Accessing Consumers of Multicast

@property (OCA_atomic, readonly, copy) NSArray *consumers;



@end
