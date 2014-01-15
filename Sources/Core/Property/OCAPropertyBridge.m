//
//  OCAPropertyBridge.m
//  Objective-Chain
//
//  Created by Martin Kiss on 9.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAPropertyBridge.h"
#import "OCAProducer+Subclass.h"
#import "OCADecomposer.h"
#import "OCATransformer.h"
#import "OCAConnection.h"





@interface OCAPropertyBridge ()


@property (atomic, readonly, strong) OCAKeyPathAccessor *accessor;


@end










@implementation OCAPropertyBridge





#pragma mark Creating Property Bridge


- (instancetype)initWithObject:(NSObject *)object keyPathAccessor:(OCAKeyPathAccessor *)accessor options:(OCAPropertyOptions)options {
    self = [super init];
    if (self) {
        OCAAssert(object != nil, @"Need an object.") return nil;
        
        OCAPropertyBridge *existing = [OCAPropertyBridge existingPropertyOnObject:object keyPathAccessor:accessor options:options];
        if (existing) return existing;
        
        self->_object = object;
        self->_accessor = accessor;
        self->_options = options;
        
        [object addObserver:self
                 forKeyPath:accessor.keyPath
                    options:(NSKeyValueObservingOptionInitial
                             | NSKeyValueObservingOptionOld
                             | NSKeyValueObservingOptionNew)
                    context:nil];
        
        //TODO: Attach and detach on demand.
        
        [object.decomposer addOwnedObject:self cleanup:^(__unsafe_unretained NSObject *owner){
            [owner removeObserver:self forKeyPath:self.accessor.keyPath];
            [self finishProducingWithError:nil];
        }];
    }
    return self;
}


+ (instancetype)existingPropertyOnObject:(NSObject *)object keyPathAccessor:(OCAKeyPathAccessor *)accessor options:(OCAPropertyOptions)options {
    return [object.decomposer findOwnedObjectOfClass:self usingBlock:^BOOL(OCAPropertyBridge *ownedProperty) {
        BOOL equalAccessor = [ownedProperty.accessor isEqual:accessor];
        BOOL equalOptions = (ownedProperty.options == options);
        return (equalAccessor && equalOptions);
    }];
}


- (NSString *)keyPath {
    return self.accessor.keyPath;
}


- (NSString *)memberPath {
    return self.accessor.structureAccessor.memberDescription;
}


- (Class)valueClass {
    if (self.options & OCAPropertyOptionIncludePreviousValue) return [NSArray class];
    else return self.accessor.valueClass;
}





#pragma mark Using Property


- (id)value {
    return [self.accessor accessObject:self.object];
}


- (void)setValue:(id)value {
    [self.accessor modifyObject:self.object withValue:value];
}





#pragma mark Producing Values


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //TODO: OCAKeyValueChange class
    
    OCAStructureAccessor *structureAccessor = self.accessor.structureAccessor;
    
    id old = [change objectForKey:NSKeyValueChangeOldKey];
    if (old == NSNull.null) old = nil;
    if (structureAccessor) {
        old = [structureAccessor accessObject:old];
    }
    
    id new = [change objectForKey:NSKeyValueChangeNewKey];
    if (new == NSNull.null) new = nil;
    if (structureAccessor) {
        new = [structureAccessor accessObject:new];
    }
    
    if (OCAEqual(old, new)) return;
    
    if (self.options & OCAPropertyOptionIncludePreviousValue) {
        [self produceValue:@[ old ?: NSNull.null, new ?: NSNull.null ]];
    }
    else {
        [self produceValue:new];
    }
}


- (id)lastValue {
    id object = self.object;
    
    if (self.options & OCAPropertyOptionIncludePreviousValue)
        // We never store the previous property value, so we just return NSNull.
        return @[ NSNull.null, [self.accessor accessObject:object] ];
    else
        return [self.accessor accessObject:object];
}


- (void)setLastValue:(id)value {
    // Nothing. Don't store last value.
}





#pragma mark Consuming Values


- (Class)consumedValueClass {
    return self.accessor.valueClass;
}


- (void)consumeValue:(id)value {
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
    return [NSString stringWithFormat:@"%@ “%@” of %@:%p", self.shortDescription, self.accessor.keyPath, object.class, object];
}


- (NSDictionary *)debugDescriptionValues {
    return @{
             @"object": [self.object debugDescription],
             @"lastValue": self.lastValue,
             @"accessor": self.accessor,
             };
}





#pragma mark Binding Properties


- (NSArray *)bindTo:(OCAPropertyBridge *)property {
    return [self bindWithTransform:nil to:property];
}


- (NSArray *)bindWithTransform:(NSValueTransformer *)transformer to:(OCAPropertyBridge *)property {
    if (transformer) {
        OCAAssert([transformer.class allowsReverseTransformation], @"Need reversible transformer for two-way binding.") return nil;
    }
    
    OCAConnection *there = [[OCAConnection alloc] initWithProducer:self
                                                             queue:nil
                                                            filter:nil
                                                         transform:transformer
                                                          consumer:property];
    OCAConnection *andBackAgain = [[OCAConnection alloc] initWithProducer:property
                                                                    queue:nil
                                                                   filter:nil
                                                                transform:[transformer reversed]
                                                                 consumer:self];
    return @[ there, andBackAgain ];
}





@end


