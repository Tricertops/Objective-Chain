//
//  OCAProducer.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//
//

#import "OCAProducer+Private.h"





@interface OCAProducer ()


@property (OCA_atomic, readonly, strong) NSMutableArray *mutableConnections;


@end










@implementation OCAProducer





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





@end
