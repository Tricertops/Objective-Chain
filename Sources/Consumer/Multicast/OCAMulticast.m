//
//  OCAMulticast.m
//  Objective-Chain
//
//  Created by Martin Kiss on 6.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAMulticast.h"





@interface OCAMulticast ()


@property (OCA_atomic, readonly, strong) Class consumedValueClass;


@end










@implementation OCAMulticast





#pragma mark Creating Multicast


- (instancetype)initWithConsumers:(NSArray *)consumers {
    self = [super init];
    if (self) {
        self->_consumers = [consumers copy];
        self->_consumedValueClass = [self valueClassForClasses:[self->_consumers valueForKeyPath:OCAKeypathUnsafe(consumedValueClass)]];
    }
    return self;
}


+ (instancetype)multicast:(NSArray *)consumers {
    return [[self alloc] initWithConsumers:consumers];
}





#pragma mark Lifetime of Multicast


- (void)consumeValue:(id)value {
    for (id<OCAConsumer> consumer in self.consumers) {
        if ([self canForwardValue:value toConsumer:consumer]) {
            [consumer consumeValue:value];
        }
    }
}


- (BOOL)canForwardValue:(id)value toConsumer:(id<OCAConsumer>)consumer {
    if ( ! value) return YES;
    
    Class consumerValueClass = [consumer consumedValueClass];
    if ( ! consumerValueClass) return YES;
    
    return [value isKindOfClass:consumerValueClass];
}


- (void)finishConsumingWithError:(NSError *)error {
    for (id<OCAConsumer> consumer in self.consumers) {
        [consumer finishConsumingWithError:error];
    }
    self->_consumers = nil;
}





#pragma mark Describing Subscriber


- (NSString *)description {
    return [NSString stringWithFormat:@"Multicast for %@ to { %@ }",
            [[self.consumedValueClass description] stringByAppendingString:@"s"] ?: @"anything",
            [self.consumers valueForKeyPath:OCAKeypath(NSObject, description)]];
}


- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@ %p; consumedValueClass = %@; consumers = %@>", self.class, self, self.consumedValueClass, self.consumers];
}





@end










@implementation OCAProducer (OCAMulticast)





- (OCAMulticast *)multicast:(id<OCAConsumer>)consumer, ... NS_REQUIRES_NIL_TERMINATION {
    OCAMulticast *multicast = [[OCAMulticast alloc] initWithConsumers:NSArrayFromVariadicArguments(consumer)];
    [self connectTo:multicast];
    return multicast;
}





@end


