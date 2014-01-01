//
//  OCAConnection.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAConnection+Private.h"
#import "OCAProducer+Private.h"
#import "OCAConsumer+Protocol.h"





@interface OCAConnection ()

@end










@implementation OCAConnection





#pragma mark Creating Connection


- (instancetype)initWithProducer:(OCAProducer *)producer {
    self = [super init];
    if (self) {
        OCAAssert(producer != nil, @"Missing producer!") return nil;
        
        self->_producer = producer;
        [producer addConnection:self];
    }
    return self;
}





#pragma mark Closing Connection


- (void)close {
    self->_closed = YES;
    [self->_producer removeConnection:self];
    self->_producer = nil;
    
    self.transformer = nil;
    self.predicate = nil;
    self.consumer = nil;
}


- (void)dealloc {
    [self close];
}





#pragma mark Receiving From Producer


- (void)producerDidProduceValue:(id)value {
    if (self.closed) return;
    
    id transformedValue = (self.transformer
                           ? [self.transformer transformedValue:value]
                           : value);
    BOOL passes = ( ! self.predicate || [self.predicate evaluateWithObject:transformedValue]);
    
    if (passes) {
        [self.consumer receiveValue:transformedValue];
    }
}


- (void)producerDidFinishWithError:(NSError *)error {
    [self.consumer finishWithError:error];
    [self close];
}





@end


