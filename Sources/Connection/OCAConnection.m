//
//  OCAConnection.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAConnection+Private.h"
#import "OCAProducer+Private.h"
#import "OCAConsumer.h"
#import "OCATransformer.h"





@interface OCAConnection ()

@end










@implementation OCAConnection





#pragma mark Creating Connection


- (instancetype)initWithProducer:(OCAProducer *)producer filter:(NSPredicate *)predicate transform:(NSValueTransformer *)transformer consumer:(id<OCAConsumer>)consumer {
    self = [super init];
    if (self) {
        OCAAssert(producer != nil, @"Missing producer!") return nil;
        OCAAssert(consumer != nil, @"Missing consumer!") return nil;
        OCAAssert(producer != consumer, @"Forbidden to connect object to itself!") return nil;
        
        //TODO: Infer default transformers for known classes.
        if (transformer) {
            OCAAssert([self isClass:producer.valueClass compatibleWithClass:[transformer.class valueClass]], @"Cannot create Connection with incompatible classes: producer of %@, transformer for %@.", producer.valueClass, [transformer.class valueClass]) return nil;
            OCAAssert([self isClass:[transformer.class transformedValueClass] compatibleWithClass:[consumer consumedValueClass]], @"Cannot create Connection with incompatible classes: transformer of %@, consumer for %@.", [transformer.class transformedValueClass], [consumer consumedValueClass]) return nil;
        }
        else {
            OCAAssert([self isClass:producer.valueClass compatibleWithClass:[consumer consumedValueClass]], @"Cannot create Connection with incompatible classes: producer of %@, consumer for %@.", producer.valueClass, [consumer consumedValueClass]) return nil;
        }
        
        self->_enabled = YES;
        
        self->_producer = producer;
        self->_filter = predicate;
        self->_transformer = transformer;
        self->_consumer = consumer;
        
        [producer addConnection:self];
    }
    return self;
}





#pragma mark Closing Connection


- (void)close {
    [self willChangeValueForKey:@"closed"];
    self->_closed = YES;
    [self didChangeValueForKey:@"closed"];
    
    self.enabled = NO;
    
    [self->_producer removeConnection:self];
    self->_producer = nil;
    self->_consumer = nil;
    
    self->_transformer = nil;
    self->_filter = nil;
}


- (void)dealloc {
    [self close];
}





#pragma mark Receiving From Producer


- (void)producerDidProduceValue:(id)value {
    if (self.closed) return;
    if ( ! self.enabled) return;
    
    BOOL passes = ( ! self.filter || [self.filter evaluateWithObject:value]);
    if ( ! passes) return;
    
    id transformedValue = (self.transformer
                           ? [self.transformer transformedValue:value]
                           : value);
    
    BOOL outputValid = [self validateObject:&transformedValue ofClass:[self.consumer consumedValueClass]];
    if ( ! outputValid) return;
    
    [self.consumer consumeValue:transformedValue];
}


- (void)producerDidFinishWithError:(NSError *)error {
    [self.consumer finishConsumingWithError:error];
    [self close];
}





#pragma mark Describing Connection


- (NSString *)descriptionName {
    return @"Connection";
}


- (NSString *)description {
    NSMutableString *d = [[NSMutableString alloc] init];
    [d appendString:(self.closed? @"Closed connection" : (self.enabled? @"Connection" : @"Disabled connection"))];
    [d appendString:@"\n"];
    [d appendFormat:@"Producer: %@\n", self.producer];
    if (self.filter) [d appendFormat:@"Filter: %@\n", self.filter];
    if (self.transformer) [d appendFormat:@"Transform: %@\n", self.transformer];
    [d appendFormat:@"Consumer: %@", self.consumer];
    if ([self.consumer isKindOfClass:[OCAProducer class]]) {
        OCAProducer *bridge = self.consumer;
        [d appendFormat:@" with %@ other connections", (bridge.connections.count ? @(bridge.connections.count) : @"no")];
    }
    [d appendString:@"\n"];
    return d;
}


- (NSDictionary *)debugDescriptionValues {
    return @{
             @"producer": self.producer.debugDescription,
             @"filter": self.filter.debugDescription,
             @"transformer": self.transformer.debugDescription,
             @"consumer": [self.consumer debugDescription],
             @"enabled": (self.enabled? @"YES" : @"NO"),
             @"closed": (self.closed? @"YES" : @"NO"),
             };
}





@end


