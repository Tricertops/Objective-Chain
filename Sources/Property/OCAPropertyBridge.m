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


- (instancetype)initWithObject:(NSObject *)object keyPathAccessor:(OCAKeyPathAccessor *)accessor {
    self = [super init];
    if (self) {
        OCAAssert(object != nil, @"Need an object.") return nil;
        
        //TODO: Re-use instances.
        
        self->_object = object;
        self->_accessor = accessor;
        
        [object addObserver:self
                 forKeyPath:accessor.keyPath
                    options:(NSKeyValueObservingOptionInitial
                             | NSKeyValueObservingOptionOld
                             | NSKeyValueObservingOptionNew)
                    context:nil];
        
        [object.decomposer addOwnedObject:self cleanup:^{
            [object removeObserver:self forKeyPath:self.accessor.keyPath];
            [self finishProducingWithError:nil];
        }];
    }
    return self;
}


- (NSString *)keyPath {
    return self.accessor.keyPath;
}


- (NSString *)memberPath {
    return self.accessor.structureAccessor.memberDescription;
}


- (Class)valueClass {
    return self.accessor.valueClass;
}





#pragma mark Producing Values


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    id value = [self.accessor accessObject:self.object];
    
    if (OCAEqual(value, self.lastValue)) return;
    
    [self produceValue:value];
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





#pragma mark Binding Properties


- (NSArray *)bindTo:(OCAPropertyBridge *)property {
    return [self bindWithTransform:nil to:property];
}


- (NSArray *)bindWithTransform:(NSValueTransformer *)transformer to:(OCAPropertyBridge *)property {
    OCAAssert([transformer.class allowsReverseTransformation], @"Need reversible transformer for two-way binding.") return nil;
    
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


