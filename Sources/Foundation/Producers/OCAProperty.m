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
#import "OCAThrottle.h"
#import "OCAPredicate.h"
#import "OCAFilter.h"
#import "OCAContext.h"
#import "OCASubscriber.h"
#import "OCAInterpolator.h"
#import "OCAMutableArrayProxy.h"
#import <objc/runtime.h>






@interface OCAPropertyChangePrivateBridge : OCABridge @end
@implementation OCAPropertyChangePrivateBridge

+ (instancetype)privateBridgeForKeyPath:(NSString *)keyPath valueClass:(Class)valueClass {
    OCAKeyPathAccessor *accessor = [OCAKeyPathAccessor accessorForObjectClass:[OCAKeyValueChange class]
                                                                      keyPath:keyPath
                                                                     objCType:@encode(id)
                                                                   valueClass:valueClass];
    OCAPropertyChangePrivateBridge *privateBridge = [[OCAPropertyChangePrivateBridge alloc] initWithTransformer:[OCATransformer access:accessor]];
    return privateBridge;
}

- (Class)consumedValueClass {
    return nil;
}

@end










@implementation OCAProperty





#pragma mark Creating Property


- (instancetype)initWithObject:(NSObject *)object keyPathAccessor:(OCAKeyPathAccessor *)accessor isPrior:(BOOL)isPrior {
    self = [super initWithValueClass:accessor.valueClass];
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


- (id<OCAConsumer>)replacementConsumerForConsumer:(id<OCAConsumer>)consumer {
    if ([consumer isKindOfClass:[OCAPropertyChangePrivateBridge class]]) {
        return consumer;
    }
    else {
        // Trick: Public consumers will get bridged so they will not receive Change objects.
        OCAPropertyChangePrivateBridge *privateBridge = [self privateBridgeForLatest];
        [privateBridge addConsumer:consumer];
        
        return privateBridge;
    }
}


- (void)didAddConsumer:(id<OCAConsumer>)consumer {
    // Trick: Get real last value as Change object. Bypasses overriden implementation intended for public.
    OCAKeyValueChange *lastChange = [super lastValue];
    if (lastChange) {
        // It there was at least one sent value, send the last one.
        [consumer consumeValue:lastChange];
    }
    if (self.isFinished) {
        // I we already finished remove immediately.
        [consumer finishConsumingWithError:self.error];
        [self removeConsumer:consumer];
    }
}


- (OCAPropertyChangePrivateBridge *)privateBridgeForSelector:(SEL)selector keyPath:(NSString *)keyPath valueClass:(Class)valueClass {
    return [self privateBridgeForSelector:selector block:^OCAPropertyChangePrivateBridge *{
        return [OCAPropertyChangePrivateBridge privateBridgeForKeyPath:keyPath valueClass:valueClass];
    }];
}


- (OCAPropertyChangePrivateBridge *)privateBridgeForSelector:(SEL)selector transformer:(NSValueTransformer *)transformer {
    return [self privateBridgeForSelector:selector block:^OCAPropertyChangePrivateBridge *{
        return [[OCAPropertyChangePrivateBridge alloc] initWithTransformer:transformer];
    }];
}


- (OCAPropertyChangePrivateBridge *)privateBridgeForSelector:(SEL)selector block:(OCAPropertyChangePrivateBridge *(^)(void))block {
    return block();
    /// Reusing is disabled, since it caused some problems.
//    OCAPropertyChangePrivateBridge *bridge = objc_getAssociatedObject(self, selector);
//    if ( ! bridge) {
//        bridge = block();
//        objc_setAssociatedObject(self, selector, bridge, OBJC_ASSOCIATION_RETAIN);
//    }
//    return bridge;
}


- (OCAPropertyChangePrivateBridge *)privateBridgeForLatest {
    return [self privateBridgeForSelector:_cmd keyPath:OCAKP(OCAKeyValueChange, latestValue) valueClass:self.accessor.valueClass];
}


- (OCAPropertyChangePrivateBridge *)privateBridgeForPreviousWithLatest {
    OCAKeyPathAccessor *previousAccessor = [OCAKeyPathAccessor accessorForObjectClass:[OCAKeyValueChangeSetting class]
                                                                              keyPath:OCAKP(OCAKeyValueChangeSetting, previousValue)
                                                                             objCType:@encode(id)
                                                                           valueClass:self.accessor.valueClass];
    OCAKeyPathAccessor *latestAccessor = [OCAKeyPathAccessor accessorForObjectClass:[OCAKeyValueChangeSetting class]
                                                                            keyPath:OCAKP(OCAKeyValueChangeSetting, latestValue)
                                                                           objCType:@encode(id)
                                                                         valueClass:self.accessor.valueClass];
    NSValueTransformer *transformer = [OCATransformer branchArray:@[
                                                                    [OCATransformer access:previousAccessor],
                                                                    [OCATransformer access:latestAccessor],
                                                                    ]];
    return [self privateBridgeForSelector:_cmd transformer:transformer];
}


- (OCAPropertyChangePrivateBridge *)privateBridgeForKeyPath {
    return [self privateBridgeForSelector:_cmd keyPath:OCAKP(OCAKeyValueChange, keyPath) valueClass:[NSString class]];
}


- (OCAPropertyChangePrivateBridge *)privateBridgeForObject {
    return [self privateBridgeForSelector:_cmd keyPath:OCAKP(OCAKeyValueChange, object) valueClass:[self.object class]];
}





#pragma mark Using Property


- (id)value {
    return [self.accessor accessObject:self.object];
}


- (void)setValue:(id)value {
    [self.accessor modifyObject:self.object withValue:value];
}





#pragma mark Using Property as a Collection


- (BOOL)isCollection {
    return [self.valueClass isSubclassOfClass:[NSArray class]];
}


- (NSMutableArray *)collection {
    if ([self isCollection]) {
        OCAMutableArrayProxy *mutableProxy = [[OCAMutableArrayProxy alloc] initWithReceiver:self.object accessor:self.accessor];
        return [mutableProxy asMutableArray];
    }
    else return nil;
}


- (void)setCollection:(NSMutableArray *)collection {
    [self.collection setArray:collection];
}


- (NSUInteger)countOfCollection {
    return [self.collection count];
}


- (id)objectInCollectionAtIndex:(NSUInteger)index {
    return [self.collection objectAtIndex:index];
}


- (void)insertObject:(id)object inCollectionAtIndex:(NSUInteger)index {
    [self.collection insertObject:object atIndex:index];
}


- (void)insertCollection:(NSArray *)array atIndexes:(NSIndexSet *)indexes {
    [self.collection insertObjects:array atIndexes:indexes];
}


- (void)removeObjectFromCollectionAtIndex:(NSUInteger)index {
    [self.collection removeObjectAtIndex:index];
}


- (void)removeCollectionAtIndexes:(NSIndexSet *)indexes {
    [self.collection removeObjectsAtIndexes:indexes];
}


- (void)replaceObjectInCollectionAtIndex:(NSUInteger)index withObject:(id)object {
    [self.collection replaceObjectAtIndex:index withObject:object];
}


- (void)replaceCollectionAtIndexes:(NSIndexSet *)indexes withCollection:(NSArray *)array {
    [self.collection replaceObjectsAtIndexes:indexes withObjects:array];
}


- (void)addObject:(id)object {
    if ( ! [self.collection containsObject:object]) {
        [self.collection addObject:object];
    }
}


- (void)removeObject:(id)object {
    [self.collection removeObject:object];
}





#pragma mark Using Property as a Number


- (BOOL)isNumber {
    return [self.valueClass isSubclassOfClass:[NSNumber class]];
}


- (OCAReal)number {
    NSNumber *value = self.value;
    if ([value isKindOfClass:[NSNumber class]]) {
        return value.doubleValue;
    }
    else return NAN;
}


- (void)setNumber:(double)number {
    if ([self isNumber]) {
        self.value = @(number);
    }
}


- (id<OCAConsumer>)consumeAdditions {
    OCAWeakify(self);
    return [OCASubscriber subscribeForClass:[NSNumber class] handler:^(NSNumber *value) {
        OCAStrongify(self);
        self.number += value.doubleValue;
    }];
}


- (OCAProducer *)produceInterpolatedWithDuration:(NSTimeInterval)duration {
    
    OCABridge *bridge = [OCABridge bridgeForClass:[NSNumber class]];
    
    __block __weak OCAInterpolator *interpolator = nil; // Weak, because it will deallocate automatically once finished.
    
    [[self produceChanges] subscribeForClass:[OCAKeyValueChangeSetting class] handler:^(OCAKeyValueChangeSetting *change) {
        
        [interpolator finishWithLastValue:YES]; // Will stop and display final value.
        
        OCAReal previous = [change.previousValue doubleValue];
        OCAReal latest = [change.latestValue doubleValue];
        OCAInterpolator *newInterpolator = [OCAInterpolator interpolatorWithDuration:duration
                                                             frequency:30
                                                             fromValue:previous
                                                               toValue:latest];
        [newInterpolator addConsumer:bridge];
        interpolator = newInterpolator;
    }];
    return bridge;
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


- (BOOL)validateProducedValue:(id)value {
    return [self validateObject:&value ofClass:[OCAKeyValueChange class]];
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


- (void)repeatLastValue {
    OCAKeyValueChange *change = [super lastValue];
    [self produceValue:change];
}





#pragma mark Consuming Values


- (Class)consumedValueClass {
    return nil;
}


- (NSArray *)consumedValueClasses {
    return @[
             self.accessor.valueClass ?: NSObject.class,
             [OCAKeyValueChange class],
             ];
}


- (void)consumeValue:(id)value {
    if ([value isKindOfClass:[OCAKeyValueChange class]]) {
        OCAKeyValueChange *change = (OCAKeyValueChange *)value;
        [change applyToProperty:self]; // Those subclasses know what to do.
    }
    else {
        [self.accessor modifyObject:self.object withValue:value];
    }
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
    OCAPropertyChangePrivateBridge *bridge = [self privateBridgeForLatest];
    [self addConsumer:bridge];
    return bridge;
}


- (OCAProducer *)producePreviousWithLatest {
    OCAPropertyChangePrivateBridge *bridge = [self privateBridgeForPreviousWithLatest];
    [self addConsumer:bridge];
    return bridge;
}


- (OCAProducer *)produceKeyPath {
    OCAPropertyChangePrivateBridge *bridge = [self privateBridgeForKeyPath];
    [self addConsumer:bridge];
    return bridge;
}


- (OCAProducer *)produceObject {
    OCAPropertyChangePrivateBridge *bridge = [self privateBridgeForObject];
    [self addConsumer:bridge];
    return bridge;
}


- (OCAProducer *)produceChanges {
    OCAKeyValueChangeSetting *initialFakeSetting = [[OCAKeyValueChangeSetting alloc] initWithObject:self.object
                                                                                            keyPath:self.accessor.keyPath
                                                                                             change:@{
                                                                                                      NSKeyValueChangeKindKey: @(NSKeyValueChangeSetting),
                                                                                                      }
                                                                                  structureAccessor:nil];
    
    OCAPropertyChangePrivateBridge *bridge = [[OCAPropertyChangePrivateBridge alloc] initWithTransformer:nil];
    [self addConsumer:bridge];
    
    /// Initial fake setting for cases, when collection was mutated before, so the observer will not receive last mutation, which can lead to inconsistencies.
    [bridge produceValue:initialFakeSetting];
    return bridge;
}





#pragma mark Binding Properties


- (void)bindWith:(OCAProperty *)otherProperty CONVENIENCE {
    [self addConsumer:otherProperty];
    [[otherProperty skipFirst:1] addConsumer:self];
}


- (void)bindTransformed:(NSValueTransformer *)transformer with:(OCAProperty *)otherProperty CONVENIENCE {
    if (transformer) {
        OCAAssert([transformer.class allowsReverseTransformation], @"Need reversible transformer for two-way binding.") return;
    }
    OCABridge *bridge = [[OCABridge alloc] initWithTransformer:transformer];
    [self addConsumer:bridge];
    [bridge addConsumer:otherProperty];
    
    OCABridge *reversedBridge = [[OCABridge alloc] initWithTransformer:[transformer reversed]];
    [[otherProperty skipFirst:1] addConsumer:reversedBridge];
    [reversedBridge addConsumer:self];
}


- (void)bindThrottled:(OCAThrottle *)throttle transformed:(NSValueTransformer *)transformer with:(OCAProperty *)property {
    if (transformer) {
        OCAAssert([transformer.class allowsReverseTransformation], @"Need reversible transformer for two-way binding.") return;
    }
    OCAAssert(throttle != nil, @"Throttle needed") return;
    
    /// Throttling affects production of values in time, which brings feedback problems.
    
    /// First feedback type is when Throttle produces value and this value returns back to Self. This value may already be transformed and not really equal to the original.
    NSPredicate *predicate = [[OCAPredicate isProperty:OCAProperty(throttle, isThrottled, BOOL)] negate];
    OCAFilter *filter = [OCAFilter filterWithPredicate:predicate];
    
    /// Second feedback type is when the Other proerty is changed by external source, it changes Self and triggers Throttling back to the Other property. This change is delayed and causes glitches.
    __block BOOL preventFeedback = NO;
    OCAContext *feedbackContext = [OCAContext custom:^(OCAContextExecutionBlock executionBlock) {
        BOOL previousValue = preventFeedback;
        preventFeedback = YES;
        executionBlock(); // The Filter will not pass.
        preventFeedback = previousValue;
    }];
    OCAFilter *feedbackFilter = [OCAFilter filterWithPredicate:[OCAPredicate predicateForClass:nil block:^BOOL(id object) {
        return ! preventFeedback; // Block when produced in the Context.
    }]];
    
    if (transformer) {
        OCABridge *bridge = [[OCABridge alloc] initWithTransformer:transformer];
        // There
        [self addConsumer:feedbackFilter];
        [feedbackFilter addConsumer:throttle];
        [throttle addConsumer:bridge];
        [bridge addConsumer:property];
        
        OCABridge *reversedBridge = [[OCABridge alloc] initWithTransformer:[transformer reversed]];
        // Back
        [property addConsumer:filter];
        [filter connectTo:feedbackContext];
        [feedbackContext addConsumer:reversedBridge];
        [reversedBridge addConsumer:self];
        
    } else {
        // There
        [self addConsumer:feedbackFilter];
        [feedbackFilter addConsumer:throttle];
        [throttle addConsumer:property];
        
        // Back
        [property addConsumer:filter];
        [filter connectTo:feedbackContext];
        [feedbackContext addConsumer:self];
    }
}


- (void)connectTransformedCollection:(NSValueTransformer *)transformer toProperty:(OCAProperty *)property {
    [[[self produceChanges] transformValues:
      [OCATransformer fromClass:[OCAKeyValueChange class] toClass:[OCAKeyValueChange class]
                      asymetric:^OCAKeyValueChange *(id input) {
                          //TODO: Optimize setting change
                          if ([input respondsToSelector:@selector(copyWithTransformedInsertedObjects:)]) {
                              return [input copyWithTransformedInsertedObjects:transformer];
                          }
                          else {
                              return input;
                          }
                      }],
      nil] connectTo:property];
}



@end


