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
    
    self.transformer = nil;
    self.filter = nil;
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


- (NSString *)description {
    NSString *adjective = (self.closed? @"closed " : (self.enabled? @"" : @"disabled "));
    return [NSString stringWithFormat:@"%@connection from %@, filter (%@), transform %@, to %@", adjective, self.producer, self.filter, self.transformer, self.consumer];
}


- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@ %p; producer = %@; filter = %@; transformer = %@; consumer = %@; enabled = %@; closed = %@>", self.class, self, self.producer.debugDescription, self.filter.debugDescription, self.transformer.debugDescription, [self.consumer debugDescription], (self.enabled? @"YES" : @"NO"), (self.closed? @"YES" : @"NO")];
}





@end


