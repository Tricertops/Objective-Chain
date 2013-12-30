//
//  OCAConnection.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//
//

#import "OCAConnection+Private.h"
#import "OCAProducer+Private.h"





@interface OCAConnection ()

@end










@implementation OCAConnection





#pragma mark Creating Connection


- (instancetype)initWithProducer:(id<OCAProducer>)producer {
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
}


- (void)dealloc {
    [self close];
}





#pragma mark Receiving From Producer


- (void)producerDidProduceValue:(id)value {
    if (self.closed) return;
    
}


- (void)producerDidFinishWithError:(NSError *)error {
    [self close];
}





@end
