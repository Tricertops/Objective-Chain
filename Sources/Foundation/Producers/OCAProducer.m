//
//  OCAProducer.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAProducer+Subclass.h"
#import "OCAHub.h"
#import "OCABridge.h"
#import "OCATransformer+Core.h"
#import "OCAVariadic.h"





@interface OCAProducer ()


@property (atomic, readwrite, assign) NSUInteger numberOfSentValues;
@property (atomic, readwrite, assign) BOOL finished;
@property (atomic, readwrite, strong) NSError *error;

@property (atomic, readonly, strong) NSMutableArray *mutableConsumers;


@end










@implementation OCAProducer





#pragma mark Creating Producer


- (instancetype)init {
    return [self initWithValueClass:nil];
}


- (instancetype)initWithValueClass:(Class)valueClass {
    self = [super init];
    if (self) {
        OCAAssert(self.class != [OCAProducer class], @"Cannot instantinate abstract class. You may want to use OCACommand to produce values manually.") return nil;
        
        self->_valueClass = valueClass;
        self->_mutableConsumers = [[NSMutableArray alloc] init];
    }
    return self;
}





#pragma mark Managing Consumers


- (NSArray *)consumers {
    return [self.mutableConsumers copy];
}


- (id<OCAConsumer>)replacementConsumerForConsumer:(id<OCAConsumer>)consumer {
    OCAAssert([self isClass:self.valueClass compatibleWithClass:[consumer consumedValueClass]], @"Incompatible classes: %@ to %@", self.valueClass, [consumer consumedValueClass]) return nil;
    return consumer;
}


- (void)addConsumer:(id<OCAConsumer>)consumer {
    if ( ! consumer) return;
    consumer = [self replacementConsumerForConsumer:consumer];
    if ( ! consumer) return;
    
    [self willAddConsumer:consumer];
    
    NSMutableArray *consumers = self.mutableConsumers;
    @synchronized(consumers) {
        [consumers addObject:consumer];
    }
    
    [self didAddConsumer:consumer];
}


- (void)willAddConsumer:(id<OCAConsumer>)consumer {
    
}


- (void)didAddConsumer:(id<OCAConsumer>)consumer {
    if (self.finished) {
        // I we already finished remove immediately.
        [consumer finishConsumingWithError:self.error];
        [self removeConsumer:consumer];
    }
    else if (self.numberOfSentValues > 0) {
        // It there was at least one sent value, send the last one.
        [consumer consumeValue:self.lastValue];
    }
}


- (void)removeConsumer:(id<OCAConsumer>)consumer {
    [self willRemoveConsumer:consumer];
    
    NSMutableArray *consumers = self.mutableConsumers;
    @synchronized(consumers) {
        [consumers removeObjectIdenticalTo:consumer];
    }
    
    [self didRemoveConsumer:consumer];
}


- (void)willRemoveConsumer:(id<OCAConsumer>)consumer {
    
}


- (void)didRemoveConsumer:(id<OCAConsumer>)consumer {
    
}


- (void)removeAllConsumers {
    for (id<OCAConsumer> consumer in self.consumers) {
        [self removeConsumer:consumer];
    }
}





#pragma mark Lifetime of Producer


- (BOOL)validateProducedValue:(id)value {
    return [self validateObject:&value ofClass:self.valueClass];
}


- (void)produceValue:(id)value {
    if ( ! [self validateProducedValue:value]) return;
    
    if (self.finished) return;
    self.lastValue = value;
    self.numberOfSentValues ++;
    
    for (id<OCAConsumer> consumer in [self.mutableConsumers copy]) {
        id consumedValue = value; // Always new variable.
        BOOL consumedValid = [self validateObject:&consumedValue ofClass:[consumer consumedValueClass]];
        if (consumedValid) {
            [consumer consumeValue:consumedValue];
        }
    }
}


- (void)finishProducingWithError:(NSError *)error {
    if (self.finished) return;
    
    self.finished = YES;
    self.error = error;
    
    NSArray *consumers = [self.mutableConsumers copy];
    [self.mutableConsumers setArray:nil];
    
    for (id<OCAConsumer> consumer in consumers) {
        [consumer finishConsumingWithError:error];
        [self removeConsumer:consumer];
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
             @"valueClass": self.valueClass ?: @"nil",
             @"lastValue": self.lastValue ?: @"nil",
             @"finished": (self.finished? @"YES" : @"NO"),
             @"error": self.error ?: @"nil",
             @"consumers": @(self.consumers.count),
             };
}





@end










@implementation OCAProducer (Chaining)




- (void)connectTo:(id<OCAConsumer>)consumer {
    [self addConsumer:consumer];
}





- (OCAHub *)mergeWith:(OCAProducer *)producer, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray *producers = OCAArrayFromVariadicArguments(producer);
    [producers insertObject:self atIndex:0];
    return [[OCAHub alloc] initWithType:OCAHubTypeMerge producers:producers];
}


- (OCAHub *)combineWith:(OCAProducer *)producer, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray *producers = OCAArrayFromVariadicArguments(producer);
    [producers insertObject:self atIndex:0];
    return [[OCAHub alloc] initWithType:OCAHubTypeCombine producers:producers];
}


- (OCAHub *)dependOn:(OCAProducer *)producer, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray *producers = OCAArrayFromVariadicArguments(producer);
    [producers insertObject:self atIndex:0];
    return [[OCAHub alloc] initWithType:OCAHubTypeDependency producers:producers];
}





- (OCABridge *)transformValues:(NSValueTransformer *)firstTransformer, ... NS_REQUIRES_NIL_TERMINATION {
    NSArray *transformersArray = OCAArrayFromVariadicArguments(firstTransformer);
    NSValueTransformer *transformer = (transformersArray.count <= 1
                                       ? transformersArray.firstObject
                                       : [OCATransformer sequence:transformersArray]);
    OCABridge *bridge = [[OCABridge alloc] initWithTransformer:transformer];
    [self addConsumer:bridge];
    return bridge;
}





@end


