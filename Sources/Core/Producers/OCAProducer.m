//
//  OCAProducer.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAProducer+Subclass.h"
#import "OCAConnection+Private.h"





@interface OCAProducer ()


@property (atomic, readwrite, assign) NSUInteger numberOfSentValues;
@property (atomic, readwrite, assign) BOOL finished;
@property (atomic, readwrite, strong) NSError *error;

@property (atomic, readonly, strong) NSMutableArray *mutableConnections;


@end










@implementation OCAProducer





#pragma mark Creating Producer

- (instancetype)init {
    return [self initWithValueClass:nil];
}


- (instancetype)initWithValueClass:(Class)valueClass {
    self = [super init];
    if (self) {
        OCAAssert(self.class != [OCAProducer class], @"Cannot instantinate abstract class.") return nil;
        
        self->_valueClass = valueClass;
        self->_mutableConnections = [[NSMutableArray alloc] init];
    }
    return self;
}





#pragma mark Managing Connections


- (NSArray *)connections {
    return [self.mutableConnections copy];
}


- (void)addConnection:(OCAConnection *)connection {
    [self willAddConnection:connection];
    
    NSMutableArray *connections = self.mutableConnections;
    @synchronized(connections) {
        [connections addObject:connection];
    }
    
    if (self.finished) {
        // I we already finished remove immediately.
        [connection producerDidFinishWithError:self.error];
        [self removeConnection:connection];
    }
    else if (self.numberOfSentValues > 0) {
        // It there was at least one sent value, send the last one.
        [connection producerDidProduceValue:self.lastValue];
    }
    
    [self didAddConnection:connection];
}


- (void)willAddConnection:(OCAConnection *)connection {
    
}


- (void)didAddConnection:(OCAConnection *)connection {
    
}


- (void)removeConnection:(OCAConnection *)connection {
    [self willRemoveConnection:connection];
    
    NSMutableArray *connections = self.mutableConnections;
    @synchronized(connections) {
        [connections removeObjectIdenticalTo:connection];
    }
    
    [self didRemoveConnection:connection];
}


- (void)willRemoveConnection:(OCAConnection *)connection {
    
}


- (void)didRemoveConnection:(OCAConnection *)connection {
    
}





#pragma mark Connecting to Producer


- (OCAConnection *)connectTo:(id<OCAConsumer>)consumer {
    return [self connectOn:nil transform:nil to:consumer];
}


- (OCAConnection *)connectOn:(OCAQueue *)queue to:(id<OCAConsumer>)consumer {
    return [self connectOn:queue transform:nil to:consumer];
}


- (OCAConnection *)connectWithTransform:(NSValueTransformer *)transformer to:(id<OCAConsumer>)consumer {
    return [self connectOn:nil transform:transformer to:consumer];
}


- (OCAConnection *)connectOn:(OCAQueue *)queue transform:(NSValueTransformer *)transformer to:(id<OCAConsumer>)consumer {
    return [[OCAConnection alloc] initWithProducer:self queue:queue transform:transformer consumer:consumer];
}





#pragma mark Lifetime of Producer


- (void)produceValue:(id)value {
    BOOL valid = [self validateObject:&value ofClass:self.valueClass];
    if ( ! valid) return;
    
    if (self.finished) return;
    self.lastValue = value;
    self.numberOfSentValues ++;
    
    for (OCAConnection *connection in [self.mutableConnections copy]) {
        [connection producerDidProduceValue:value];
    }
}

- (void)finishProducingWithError:(NSError *)error {
    if (self.finished) return;
    
    self.finished = YES;
    self.error = error;
    
    // Connections will attempt to remove themselves, but now the array is empty.
    NSArray *connections = [self.mutableConnections copy];
    [self.mutableConnections setArray:nil];
    
    for (OCAConnection *connection in connections) {
        [connection producerDidFinishWithError:error];
    }
    
}


- (void)dealloc {
    [self finishProducingWithError:nil];
}





#pragma mark Describing Producer


- (NSString *)descriptionName {
    return @"Producer";
}


- (NSString *)description {
    NSString *adjective = (self.finished? @"Finished " : @"");
    NSString *className = [[self.valueClass description] stringByAppendingString:@"s"] ?: @"something";
    return [NSString stringWithFormat:@"%@%@ of %@", adjective, self.shortDescription, className];
    // Finished Producer of NSStrings
    // Producer of something
}


- (NSDictionary *)debugDescriptionValues {
    return @{
             @"valueClass": self.valueClass,
             @"lastValue": self.lastValue,
             @"finished": (self.finished? @"YES" : @"NO"),
             @"error": self.error,
             @"connections": @(self.connections.count),
             };
}





@end


