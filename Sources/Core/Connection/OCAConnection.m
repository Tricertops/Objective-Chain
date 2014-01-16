//
//  OCAConnection.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAConnection+Private.h"
#import "OCAProducer+Subclass.h"
#import "OCAQueue.h"
#import "OCATransformer.h"
#import "OCAConsumer.h"





@interface OCAConnection ()


@property (atomic, readwrite, weak) OCAProducer *producer;
@property (atomic, readwrite, strong) OCAQueue *queue;
@property (atomic, readwrite, strong) NSValueTransformer *transformer;
@property (atomic, readwrite, strong) id<OCAConsumer> consumer;

@property (atomic, readwrite, assign) BOOL closed;


@end










@implementation OCAConnection





#pragma mark Creating Connection


- (instancetype)init {
    return [self initWithProducer:nil queue:nil transform:nil consumer:nil];
}


- (instancetype)initWithProducer:(OCAProducer *)producer queue:(OCAQueue *)queue transform:(NSValueTransformer *)transformer consumer:(id<OCAConsumer>)consumer {
    self = [super init];
    if (self) {
        OCAAssert(producer != nil, @"Missing producer!") return nil;
        OCAAssert(consumer != nil, @"Missing consumer!") return nil;
        OCAAssert(producer != consumer, @"Forbidden to connect object to itself!") return nil;
        
        //TODO: Infer default transformers for known classes.
        if (transformer) {
            OCAAssert([self isClass:producer.valueClass compatibleWithClass:[transformer.class valueClass]], @"Cannot create Connection with incompatible classes: producer of %@, transformer for %@.", producer.valueClass, [transformer.class valueClass]) return nil;
            OCAAssert([self isClass:[transformer.class transformedValueClass] compatibleWithClass:[consumer consumedValueClass]], @"Cannot create Connection with incompatible classes: transformer of %@, consumer for %@.", [transformer.class transformedValueClass], [consumer consumedValueClass]) return nil;
        }
        else {
            OCAAssert([self isClass:producer.valueClass compatibleWithClass:[consumer consumedValueClass]], @"Cannot create Connection with incompatible classes: producer of %@, consumer for %@.", producer.valueClass, [consumer consumedValueClass]) return nil;
        }
        
        self->_producer = producer;
        self->_enabled = YES;
        self->_queue = queue ?: [OCAQueue current];
        self->_transformer = transformer;
        self->_consumer = consumer;
        
        [producer addConnection:self];
        
        NSLog(@"Connection (%p): Allocated from [%@] to [%@]", self, self.producer, self.consumer);
    }
    return self;
}





#pragma mark Closing Connection


- (void)close {
    self.closed = YES;
    self.enabled = NO;
    
    [self.producer removeConnection:self];
    self.producer = nil;
    self.transformer = nil;
    self.consumer = nil;
}


- (void)dealloc {
    [self close];
    NSLog(@"Connection (%p): Deallocated", self);
}





#pragma mark Receiving From Producer


- (void)producerDidProduceValue:(id)value {
    if (self.closed) return;
    if ( ! self.enabled) return;
    
    [self.queue performBlockAndTryWait:^{
        
        id transformedValue = (self.transformer ? [self.transformer transformedValue:value] : value);
        
        BOOL outputValid = [self validateObject:&transformedValue ofClass:[self.consumer consumedValueClass]];
        if ( ! outputValid) return;
        
        [self.consumer consumeValue:transformedValue];
    }];
}


- (void)producerDidFinishWithError:(NSError *)error {
    if (self.closed) return;
    
    if (self.enabled) {
        [self.queue performBlockAndTryWait:^{
            [self.consumer finishConsumingWithError:error];
        }];
    }
    
    [self close];
}





#pragma mark Describing Connection


- (instancetype)describe:(NSString *)format, ... NS_REQUIRES_NIL_TERMINATION {
    self.name = NSStringFromFormat(format);
    return self;
}


- (NSString *)descriptionName {
    return @"Connection";
}


- (NSString *)description {
    NSMutableString *d = [[NSMutableString alloc] init];
    [d appendString:(self.closed? @"Closed connection" : (self.enabled? @"Connection" : @"Disabled connection"))];
    if (self.name.length) {
        [d appendFormat:@" “%@”", self.name];
    }
    [d appendString:@"\n"];
    [d appendFormat:@"Producer: %@\n", self.producer];
    [d appendFormat:@"Queue: %@\n", self.queue];
    if (self.transformer) [d appendFormat:@"Transform: %@\n", self.transformer];
    [d appendFormat:@"Consumer: %@", self.consumer];
    if ([self.consumer isKindOfClass:[OCAProducer class]]) {
        OCAProducer *bridge = self.consumer;
        [d appendFormat:@" with %@ other connections", (bridge.connections.count ? @(bridge.connections.count) : @"no")];
    }
    [d appendString:@"\n"];
    return d;
}


- (NSDictionary *)debugDescriptionValues {
    return @{
             @"producer": self.producer.debugDescription ?: @"nil",
             @"queue": self.queue.debugDescription ?: @"nil",
             @"transformer": self.transformer.debugDescription ?: @"nil",
             @"consumer": [self.consumer debugDescription] ?: @"nil",
             @"enabled": (self.enabled? @"YES" : @"NO"),
             @"closed": (self.closed? @"YES" : @"NO"),
             @"name": self.name ?: @"nil",
             };
}





@end


