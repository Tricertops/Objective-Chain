//
//  OCABridge.m
//  Objective-Chain
//
//  Created by Martin Kiss on 5.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCABridge.h"
#import "OCAProducer+Subclass.h"
#import "OCATransformer+Core.h"
#import "OCAVariadic.h"










@implementation OCABridge





#pragma mark Creating Bridge


- (instancetype)initWithValueClass:(Class)valueClass {
    NSValueTransformer *transformer = [[OCATransformer pass] specializeFromClass:valueClass toClass:valueClass];
    return [self initWithTransformer:transformer];
}


- (instancetype)initWithTransformer:(NSValueTransformer *)transformer {
    self = [super initWithValueClass:[transformer.class transformedValueClass]];
    if (self) {
        self->_transformer = transformer ?: [OCATransformer pass];
    }
    return self;
}


+ (OCABridge *)bridgeForClass:(Class)class {
    NSValueTransformer *transformer = [[OCATransformer pass] specializeFromClass:class toClass:class];
    return [[self alloc] initWithTransformer:transformer];
}


+ (OCABridge *)bridgeWithTransformers:(NSValueTransformer *)firstTransformer, ... NS_REQUIRES_NIL_TERMINATION {
    NSArray *transformersArray = OCAArrayFromVariadicArguments(firstTransformer);
    NSValueTransformer *transformer = (transformersArray.count <= 1
                                       ? transformersArray.firstObject
                                       : [OCATransformer sequence:transformersArray]);
    return [[self alloc] initWithTransformer:transformer];
}





#pragma mark Lifetime of Bridge


- (Class)consumedValueClass {
    return [self.transformer.class valueClass];
}


- (void)consumeValue:(id)value {
    id transformedValue = [self.transformer transformedValue:value];
    [self produceValue:transformedValue];
}


- (void)finishConsumingWithError:(NSError *)error {
    [self finishProducingWithError:error];
}





@end


