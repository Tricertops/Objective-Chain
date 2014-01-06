//
//  OCAProducer.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAProducer+Private.h"
#import "OCAConnection+Private.h"





@interface OCAProducer ()


@property (OCA_atomic, readonly, strong) NSMutableArray *mutableConnections;


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
        
        [self didAddConnection:connection];
    }
}


- (void)didAddConnection:(OCAConnection *)connection {
    if (self.finished) {
        [connection producerDidFinishWithError:self.error];
    }
}


- (void)removeConnection:(OCAConnection *)connection {
    [self willRemoveConnection:connection];
    
    NSMutableArray *connections = self.mutableConnections;
    @synchronized(connections) {
        [connections removeObjectIdenticalTo:connection];
    }
}


- (void)willRemoveConnection:(OCAConnection *)connection {
}





#pragma mark Connecting to Producer


- (OCAConnection *)connectTo:(id<OCAConsumer>)consumer {
    return [self connectWithFilter:nil transform:nil to:consumer];
}


- (OCAConnection *)connectWithTransform:(NSValueTransformer *)transformer to:(id<OCAConsumer>)consumer {
    return [self connectWithFilter:nil transform:transformer to:consumer];
}


- (OCAConnection *)connectWithFilter:(NSPredicate *)predicate to:(id<OCAConsumer>)consumer {
    return [self connectWithFilter:predicate transform:nil to:consumer];
}


- (OCAConnection *)connectWithFilter:(NSPredicate *)predicate transform:(NSValueTransformer *)transformer to:(id<OCAConsumer>)consumer {
    return [[OCAConnection alloc] initWithProducer:self filter:predicate transform:transformer consumer:consumer];
}





#pragma mark Lifetime of Producer


- (void)produceValue:(id)value {
    BOOL valid = [self validateObject:&value ofClass:self.valueClass];
    if ( ! valid) return;
    
    if (self.finished) return;
    self->_lastValue = value;
    
    for (OCAConnection *connection in [self.mutableConnections copy]) {
        [connection producerDidProduceValue:value];
    }
}


- (void)finishProducingWithError:(NSError *)error {
    if (self.finished) return;
    
    self->_finished = YES;
    self->_error = error;
    
    for (OCAConnection *connection in [self.mutableConnections copy]) {
        [connection producerDidFinishWithError:error];
    }
    
    [self.mutableConnections setArray:nil];
}





#pragma mark Describing Producer


- (NSString *)descriptionName {
    return @"Producer";
}


- (NSString *)description {
    // Producer of NSStrings
    // Finished producer of NSStrings
    return [NSString stringWithFormat:@"%@%@ of %@",
            (self.finished? @"Finished " : @""),
            (self.finished? [self.descriptionName lowercaseString] : self.descriptionName),
            [[self.valueClass description] stringByAppendingString:@"s"] ?: @"something"];
}


- (NSString *)debugDescription {
    NSDictionary *descriptionValues = [self debugDescriptionValues];
    NSMutableArray *valueStrings = [[NSMutableArray alloc] init];
    [valueStrings addObject:@""];
    [descriptionValues enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSObject *value, BOOL *stop) {
        [valueStrings addObject:[NSString stringWithFormat:@"%@ = %@", key, value]];
    }];
    
    
    return [NSString stringWithFormat:@"<%@ %p%@>",
            self.class, self, [valueStrings componentsJoinedByString:@"; "]];
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


