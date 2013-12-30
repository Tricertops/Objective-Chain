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
        [self.producer addConnection:self];
    }
    return self;
}





#pragma mark Breaking Connection


- (void)dealloc {
    [self.producer removeConnection:self];
}





#pragma mark Receiving From Producer


- (void)producerDidSendValue:(id)value {
    
}


- (void)producerDidFinishWithError:(NSError *)error {
    
}





@end
