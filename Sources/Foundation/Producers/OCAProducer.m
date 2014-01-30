//
//  OCAProducer.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAProducer+Subclass.h"





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
        OCAAssert(self.class != [OCAProducer class], @"Cannot instantinate abstract class.") return nil;
        
        self->_valueClass = valueClass;
        self->_mutableConsumers = [[NSMutableArray alloc] init];
    }
    return self;
}





#pragma mark Managing Consumers


- (NSArray *)consumers {
    return [self.mutableConsumers copy];
}


- (void)addConsumer:(id<OCAConsumer>)consumer {
    OCAAssert([self isClass:self.valueClass compatibleWithClass:[consumer consumedValueClass]], @"Incompatible classes: %@ to %@", self.valueClass, [consumer consumedValueClass]) return;
    
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





#pragma mark Connecting to Producer


- (void)consumeBy:(id<OCAConsumer>)consumer {
    [self addConsumer:consumer];
}





#pragma mark Lifetime of Producer


- (void)produceValue:(id)value {
    BOOL valid = [self validateObject:&value ofClass:self.valueClass];
    if ( ! valid) return;
    
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


