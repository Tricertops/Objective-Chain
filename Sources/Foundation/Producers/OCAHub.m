//
//  OCAHub.m
//  Objective-Chain
//
//  Created by Martin Kiss on 5.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAHub.h"
#import "OCAProducer+Subclass.h"
#import "NSArray+Ordinals.h"
#import "OCAVariadic.h"





@interface OCAHub () < OCAConsumer >


@property (atomic, readonly, strong) Class consumedValueClass;
@property (atomic, readonly, strong) NSMutableArray *mutableProducers;


@end










@implementation OCAHub





#pragma mark Creating Hub


- (instancetype)initWithType:(OCAHubType)type producers:(NSArray *)producers {
    
    NSArray *valueClasses = [producers valueForKeyPath:OCAKP(OCAProducer, valueClass)];
    Class consumedValueClass = [OCAHub consumedValueClassForType:type valueClasses:valueClasses];
    Class valueClass = [OCAHub producedValueClassForType:type valueClasses:valueClasses];
    
    self = [super initWithValueClass:valueClass];
    if (self) {
        self->_type = type;
        self->_mutableProducers = [producers mutableCopy];
        self->_consumedValueClass = consumedValueClass;
        
        [self openConnections];
    }
    return self;
}


+ (Class)consumedValueClassForType:(OCAHubType)type valueClasses:(NSArray *)valueClasses {
    switch (type) {
        case OCAHubTypeMerge: return [self valueClassForClasses:valueClasses];
        case OCAHubTypeCombine: return [self valueClassForClasses:valueClasses];
        case OCAHubTypeDependency: return [valueClasses oca_valueAtIndex:0];
    }
}


+ (Class)producedValueClassForType:(OCAHubType)type valueClasses:(NSArray *)valueClasses {
    switch (type) {
        case OCAHubTypeMerge: return [self valueClassForClasses:valueClasses];
        case OCAHubTypeCombine: return [NSArray class];
        case OCAHubTypeDependency: return [valueClasses oca_valueAtIndex:0];
    }
}


+ (instancetype)merge:(OCAProducer *)producers, ... NS_REQUIRES_NIL_TERMINATION {
    return [[self alloc] initWithType:OCAHubTypeMerge producers:OCAArrayFromVariadicArguments(producers)];
}


+ (instancetype)combine:(OCAProducer *)producers, ... NS_REQUIRES_NIL_TERMINATION {
    return [[self alloc] initWithType:OCAHubTypeCombine producers:OCAArrayFromVariadicArguments(producers)];
}





#pragma mark Lifetime of Hub


- (NSArray *)producers {
    return [self.mutableProducers copy];
}


- (void)openConnections {
    for (OCAProducer *producer in self.mutableProducers) {
        OCAAssert([producer isKindOfClass:[OCAProducer class]], @"Hub needs Producers, not %@", producer.class) continue;
        
        [producer addConsumer:self];
    }
}


- (void)consumeValue:(id)value {
    switch (self.type) {
        case OCAHubTypeMerge: {
            [self produceValue:value];
            break;
        }
        case OCAHubTypeCombine: {
            NSArray *latestValues = [self.producers valueForKeyPath:OCAKP(OCAProducer, lastValue)];
            [self produceValue:latestValues];
            break;
        }
        case OCAHubTypeDependency: {
            OCAProducer *first = self.producers.firstObject;
            [self produceValue:first.lastValue];
        }
    }
}


- (void)finishConsumingWithError:(NSError *)error {
    if (error) {
        [self finishProducingWithError:error];
    }
    else {
        switch (self.type) {
            case OCAHubTypeMerge: {
                [self removeFinishedProducers];
                if ( ! self.mutableProducers.count) {
                    [self finishProducingWithError:nil];
                }
                break;
            }
            case OCAHubTypeCombine: {
                if ([self areAllProducersFinished]) {
                    [self finishProducingWithError:error];
                }
                break;
            }
            case OCAHubTypeDependency: {
                OCAProducer *first = self.producers.firstObject;
                if (first.finished) {
                    [self finishProducingWithError:nil];
                }
                [self removeFinishedProducers];
            }
        }
    }
}


- (void)removeFinishedProducers {
    NSIndexSet *finishedIndexes = [self.mutableProducers indexesOfObjectsPassingTest:
                                   ^BOOL(OCAProducer *producer, NSUInteger idx, BOOL *stop) {
                                       return producer.finished;
                                   }];
    [self.mutableProducers removeObjectsAtIndexes:finishedIndexes];
}


- (BOOL)areAllProducersFinished {
    for (OCAProducer *producer in self.mutableProducers) {
        if ( ! producer.finished) {
            return NO;
        }
    }
    return YES;
}





@end


