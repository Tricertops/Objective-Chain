//
//  OCAProperty.m
//  Objective-Chain
//
//  Created by Martin Kiss on 9.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAProperty.h"
#import "OCAProducer+Subclass.h"
#import "OCADecomposer.h"
#import "OCATransformer.h"
#import "OCABridge.h"





@interface OCAPropertyChangePrivateBridge : OCABridge @end
@implementation OCAPropertyChangePrivateBridge

+ (instancetype)privateBridgeForKeyPath:(NSString *)keyPath valueClass:(Class)valueClass {
    OCAKeyPathAccessor *accessor = [[OCAKeyPathAccessor alloc] initWithObjectClass:[OCAKeyValueChange class]
                                                                           keyPath:keyPath
                                                                          objCType:@encode(id)
                                                                        valueClass:valueClass];
    OCAPropertyChangePrivateBridge *privateBridge = [[OCAPropertyChangePrivateBridge alloc] initWithTransformer:[OCATransformer access:accessor]];
    return privateBridge;
}

- (Class)consumedValueClass {
    return nil;
}

- (NSString *)descriptionName {
    return @"PropertyChangePrivateBridge";
}

@end










@implementation OCAProperty





#pragma mark Creating Property Bridge


- (instancetype)initWithObject:(NSObject *)object keyPathAccessor:(OCAKeyPathAccessor *)accessor isPrior:(BOOL)isPrior {
    self = [super init];
    if (self) {
        OCAAssert(object != nil, @"Need an object.") return nil;
        
        OCAProperty *existing = [OCAProperty existingPropertyOnObject:object keyPathAccessor:accessor isPrior:isPrior];
        if (existing) return existing;
        
        self->_object = object;
        self->_accessor = accessor;
        self->_isPrior = isPrior;
        
        [object addObserver:self
                 forKeyPath:accessor.keyPath
                    options:(NSKeyValueObservingOptionInitial
                             | NSKeyValueObservingOptionOld
                             | NSKeyValueObservingOptionNew
                             | (isPrior? NSKeyValueObservingOptionPrior : kNilOptions))
                    context:nil];
        
        //TODO: Attach and detach on demand.
        
        [object.decomposer addOwnedObject:self cleanup:^(__unsafe_unretained NSObject *owner){
            [owner removeObserver:self forKeyPath:self.accessor.keyPath];
            [self finishProducingWithError:nil];
        }];
    }
    return self;
}


+ (instancetype)existingPropertyOnObject:(NSObject *)object keyPathAccessor:(OCAKeyPathAccessor *)accessor isPrior:(BOOL)isPrior {
    return [object.decomposer findOwnedObjectOfClass:self usingBlock:^BOOL(OCAProperty *ownedProperty) {
        BOOL equalAccessor = [ownedProperty.accessor isEqual:accessor];
        BOOL equalIsPrior = (ownedProperty.isPrior == isPrior);
        return (equalAccessor && equalIsPrior);
    }];
}


- (NSUInteger)hash {
    return [self.object hash] ^ self.accessor.hash ^ @(self.isPrior).hash;
}


- (BOOL)isEqual:(OCAProperty *)other {
    if (self == other) return YES;
    if ( ! [other isKindOfClass:[OCAProperty class]]) return NO;
    
    return (self.object == other.object
            && OCAEqual(self.accessor, other.accessor)
            && self.isPrior == other.isPrior);
}


- (NSString *)keyPath {
    return self.accessor.keyPath;
}


- (NSString *)memberPath {
    return self.accessor.structureAccessor.memberDescription;
}


- (void)addConsumer:(id<OCAConsumer>)consumer {
    OCAPropertyChangePrivateBridge * privateBridge = nil;
    if ([consumer isKindOfClass:[OCAPropertyChangePrivateBridge class]]) {
        privateBridge = consumer;
    }
    else {
        // Trick: Public consumers will get bridged so they will not receive Change objects.
        privateBridge = [OCAPropertyChangePrivateBridge privateBridgeForKeyPath:OCAKP(OCAKeyValueChange, latestValue) valueClass:self.accessor.valueClass];
        [privateBridge addConsumer:consumer];
    }
    [super addConsumer:privateBridge];
}


- (void)didAddConsumer:(id<OCAConsumer>)consumer {
    OCAAssert([consumer isKindOfClass:[OCAPropertyChangePrivateBridge class]], @"Need private consumer.");
    
    if (self.finished) {
        // I we already finished remove immediately.
        [consumer finishConsumingWithError:self.error];
        [self removeConsumer:consumer];
    }
    else {
        // Trick: Get real last value as Change object. Bypasses overriden implementation intended for public.
        OCAKeyValueChange *lastChange = [super lastValue];
        if (lastChange) {
            // It there was at least one sent value, send the last one.
            [consumer consumeValue:lastChange];
        }
    }
}





#pragma mark Using Property


- (id)value {
    return [self.accessor accessObject:self.object];
}


- (void)setValue:(id)value {
    [self.accessor modifyObject:self.object withValue:value];
}





#pragma mark Producing Values


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)dictionary context:(void *)context {
    OCAKeyValueChange *change = [[OCAKeyValueChange alloc] initWithObject:object
                                                                  keyPath:keyPath
                                                                   change:dictionary
                                                        structureAccessor:self.accessor.structureAccessor];
    if ([change asSettingChange]) {
        OCAKeyValueChangeSetting *setting = [change asSettingChange];
        if ( ! [setting isInitial] && [setting isLatestEqualToPrevious]) return;
    }
    
    [self produceValue:change];
}


- (id)lastValue {
    // Trick: Return unwrapped latest value for public.
    OCAKeyValueChange *lastChange = [super lastValue];
    OCAAssert([lastChange isKindOfClass:[OCAKeyValueChange class]], @"Property need objectified changes") return nil;
    return lastChange.latestValue;
}


- (void)setLastValue:(id)lastValue {
    OCAAssert([lastValue isKindOfClass:[OCAKeyValueChange class]], @"Property need objectified changes") return;
    [super setLastValue:lastValue];
}





#pragma mark Consuming Values


- (Class)consumedValueClass {
    return self.accessor.valueClass;
}


- (void)consumeValue:(id)value {
    //TODO: Consume changes
    [self.accessor modifyObject:self.object withValue:value];
}


- (void)finishConsumingWithError:(NSError *)error {
    // Nothing.
}





#pragma mark Describing Properties


- (NSString *)descriptionName {
    return @"Property";
}


- (NSString *)description {
    NSObject *object = self.object;
    NSString *structMember = (self.accessor.structureAccessor? [NSString stringWithFormat:@".%@", self.accessor.structureAccessor.memberPath] : @"");
    return [NSString stringWithFormat:@"%@ “%@%@” of %@:%p", self.shortDescription, self.accessor.keyPath, structMember, object.class, object];
}


- (NSDictionary *)debugDescriptionValues {
    return @{
             @"object": [self.object debugDescription],
             @"lastValue": self.lastValue,
             @"accessor": self.accessor,
             };
}





#pragma mark Deriving Producers


- (OCAProducer *)produceLatest {
    // Trick: Public consumers will get bridged so they will not receive Change objects.
    OCAPropertyChangePrivateBridge *bridge = [OCAPropertyChangePrivateBridge privateBridgeForKeyPath:OCAKP(OCAKeyValueChange, latestValue) valueClass:self.accessor.valueClass];
    [self addConsumer:bridge];
    return bridge;
}


- (OCAProducer *)producePreviousWithLatest {
    OCAKeyPathAccessor *previousAccessor = [[OCAKeyPathAccessor alloc] initWithObjectClass:[OCAKeyValueChangeSetting class]
                                                                                   keyPath:OCAKP(OCAKeyValueChangeSetting, previousValue)
                                                                                  objCType:@encode(id)
                                                                                valueClass:self.accessor.valueClass];
    OCAKeyPathAccessor *latestAccessor = [[OCAKeyPathAccessor alloc] initWithObjectClass:[OCAKeyValueChangeSetting class]
                                                                                 keyPath:OCAKP(OCAKeyValueChangeSetting, latestValue)
                                                                                objCType:@encode(id)
                                                                              valueClass:self.accessor.valueClass];
    // Combine previous and latest values.
    NSValueTransformer *transformer = [OCATransformer branchArray:@[
                                                                    [OCATransformer access:previousAccessor],
                                                                    [OCATransformer access:latestAccessor],
                                                                    ]];
    OCAPropertyChangePrivateBridge *bridge = [[OCAPropertyChangePrivateBridge alloc] initWithTransformer:transformer];
    [self addConsumer:bridge];
    return bridge;
}


- (OCAProducer *)produceKeyPath {
    OCAPropertyChangePrivateBridge *bridge = [OCAPropertyChangePrivateBridge privateBridgeForKeyPath:OCAKP(OCAKeyValueChange, keyPath) valueClass:[NSString class]];
    [self addConsumer:bridge];
    return bridge;
}


- (OCAProducer *)produceObject {
    OCAPropertyChangePrivateBridge *bridge = [OCAPropertyChangePrivateBridge privateBridgeForKeyPath:OCAKP(OCAKeyValueChange, object) valueClass:[self.object class]];
    [self addConsumer:bridge];
    return bridge;
}


- (OCAProducer *)produceChanges {
    // Only passing bridge.
    OCAPropertyChangePrivateBridge *bridge = [[OCAPropertyChangePrivateBridge alloc] initWithTransformer:nil];
    [self addConsumer:bridge];
    return bridge;
}





#pragma mark Binding Properties


- (void)bindWith:(OCAProperty *)otherProperty CONVENIENCE {
    [self addConsumer:otherProperty];
    [otherProperty addConsumer:self];
}


- (void)bindTransformed:(NSValueTransformer *)transformer with:(OCAProperty *)otherProperty CONVENIENCE {
    if (transformer) {
        OCAAssert([transformer.class allowsReverseTransformation], @"Need reversible transformer for two-way binding.") return;
    }
    OCABridge *bridge = [[OCABridge alloc] initWithTransformer:transformer];
    [self addConsumer:bridge];
    [bridge addConsumer:otherProperty];
    
    OCABridge *reversedBridge = [[OCABridge alloc] initWithTransformer:[transformer reversed]];
    [otherProperty addConsumer:reversedBridge];
    [reversedBridge addConsumer:self];
}





@end

