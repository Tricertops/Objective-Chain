//
//  OCAProducer.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//
//

#import "OCAProducer+Private.h"
#import "OCAConnection+Producer.h"





@interface OCAProducer ()


@property (OCA_atomic, readonly, strong) NSMutableArray *mutableConnections;


@end










@implementation OCAProducer

@synthesize lastValue = _lastValue;
@synthesize finished = _finished;
@synthesize error = _error;





#pragma mark Managing Connections


OCALazyGetter(NSMutableArray *, mutableConnections) {
    return [[NSMutableArray alloc] init];
}


- (NSArray *)connections {
    return [self.mutableConnections copy];
}


- (void)addConnection:(OCAConnection *)connection {
    NSMutableArray *connections = self.mutableConnections;
    @synchronized(connections) {
        [connections addObject:connection];
    }
}


- (void)removeConnection:(OCAConnection *)connection {
    NSMutableArray *connections = self.mutableConnections;
    @synchronized(connections) {
        [connections removeObjectIdenticalTo:connection];
    }
}





#pragma mark Lifetime


- (void)sendValue:(id)value {
    if (self.finished) return;
    self->_lastValue = value;
    
    for (OCAConnection *connection in [self.mutableConnections copy]) {
        [connection producerDidProduceValue:value];
    }
}


- (void)finishWithError:(NSError *)error {
    if (self.finished) return;
    
    self->_finished = YES;
    self->_error = error;
    
    for (OCAConnection *connection in [self.mutableConnections copy]) {
        [connection producerDidFinishWithError:error];
    }
    
    [self.mutableConnections setArray:nil];
}





@end
