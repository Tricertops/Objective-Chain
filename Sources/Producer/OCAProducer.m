//
//  OCAProducer.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//
//

#import "OCAProducer+Private.h"
#import "OCAConnection+Private.h"





@interface OCAProducer ()


@property (OCA_atomic, readonly, strong) NSMutableArray *mutableConnections;


@end










@implementation OCAProducer





#pragma mark Creating Producer


- (instancetype)init {
    self = [super init];
    if (self) {
        OCAAssert(self.class != [OCAProducer class], @"Cannot instantinate abstract class.") return nil;
    }
    return self;
}





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





#pragma mark Connecting to Producer


- (OCAConnection *)connectTo:(id<OCAConsumer>)consumer {
    OCAConnection *connection = [[OCAConnection alloc] initWithProducer:self];
    connection.consumer = consumer;
    return connection;
}





#pragma mark Lifetime of Producer


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


