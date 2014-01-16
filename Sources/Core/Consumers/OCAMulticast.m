//
//  OCAMulticast.m
//  Objective-Chain
//
//  Created by Martin Kiss on 6.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAMulticast.h"
#import "OCAConnection.h"





@interface OCAMulticast ()


@property (atomic, readonly, strong) Class consumedValueClass;

@property (atomic, readwrite, copy) NSArray *consumers;


@end










@implementation OCAMulticast





#pragma mark Creating Multicast


- (instancetype)initWithConsumers:(NSArray *)consumers {
    self = [super init];
    if (self) {
        self->_consumers = [consumers copy];
        self->_consumedValueClass = [self valueClassForClasses:[self->_consumers valueForKeyPath:OCAKPUnsafe(consumedValueClass)]];
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
    self.consumers = nil;
}





#pragma mark Describing Subscriber


- (NSString *)descriptionName {
    return @"Multicast";
}


- (NSString *)description {
    NSString *className = [[self.consumedValueClass description] stringByAppendingString:@"s"] ?: @"anything";
    return [NSString stringWithFormat:@"%@ for %@ to { %@ }", self.shortDescription, className, [self.consumers componentsJoinedByString:@", "]];
    // Multicast (0x0) for NSStrings to { Subscriber (0x0) for NSStrings, Subscriber (0x0) for NSStrings }
}


- (NSDictionary *)debugDescriptionValues {
    return @{
             @"consumedValueClass": self.consumedValueClass,
             @"consumers": self.consumers,
             };
}





@end










@implementation OCAProducer (OCAMulticast)





- (OCAConnection *)multicast:(id<OCAConsumer>)consumer, ... NS_REQUIRES_NIL_TERMINATION {
    OCAMulticast *multicast = [[OCAMulticast alloc] initWithConsumers:NSArrayFromVariadicArguments(consumer)];
    return [[OCAConnection alloc] initWithProducer:self queue:nil transform:nil consumer:multicast];
}





@end


