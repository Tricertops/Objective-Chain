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


- (instancetype)initWithProducer:(OCAProducer *)producer consumer:(id<OCAConsumer>)consumer {
    self = [super init];
    if (self) {
        OCAAssert(producer != nil, @"Missing producer!") return nil;
        OCAAssert(consumer != nil, @"Missing consumer!") return nil;
        OCAAssert(producer != consumer, @"Forbidden to connect object to itself!") return nil;
        
        self->_enabled = YES;
        
        self->_producer = producer;
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
    self.predicate = nil;
}


- (void)dealloc {
    [self close];
}





#pragma mark Receiving From Producer


- (void)producerDidProduceValue:(id)value {
    if (self.closed) return;
    if ( ! self.enabled) return;
    
    BOOL passes = ( ! self.predicate || [self.predicate evaluateWithObject:value]);
    if ( ! passes) return;
    
    id transformedValue = (self.transformer
                           ? [self.transformer transformedValue:value]
                           : value);
    
    [self.consumer consumeValue:transformedValue];
}


- (void)producerDidFinishWithError:(NSError *)error {
    [self.consumer finishConsumingWithError:error];
    [self close];
}





@end


