//
//  OCABridge.m
//  Objective-Chain
//
//  Created by Martin Kiss on 5.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCABridge.h"
#import "OCAProducer+Subclass.h"
#import "OCATransformer.h"










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


+ (OCABridge *)bridge {
    return [[self alloc] initWithTransformer:nil];
}


+ (OCABridge *)bridgeForClass:(Class)class {
    NSValueTransformer *transformer = [[OCATransformer pass] specializeFromClass:class toClass:class];
    return [[self alloc] initWithTransformer:transformer];
}


+ (OCABridge *)bridgeWithTransformer:(NSValueTransformer *)transformer {
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





#pragma mark Describing Bridge


- (NSString *)descriptionName {
    return @"Bridge";
}





@end










@implementation OCAProducer (OCABridge)





- (OCABridge *)produceTransformed:(NSArray *)transformers CONVENIENCE {
    OCABridge *bridge = [[OCABridge alloc] initWithTransformer:[OCATransformer sequence:transformers]];
    [self addConsumer:bridge];
    return bridge;
}


- (OCABridge *)produceReplacement:(id)replacement CONVENIENCE {
    OCABridge *bridge = [[OCABridge alloc] initWithTransformer:[OCATransformer replaceWith:replacement]];
    [self addConsumer:bridge];
    return bridge;
}


- (OCABridge *)produceMapped:(NSDictionary *)map CONVENIENCE {
    OCABridge *bridge = [[OCABridge alloc] initWithTransformer:[OCATransformer map:map]];
    [self addConsumer:bridge];
    return bridge;
}


- (OCABridge *)produceIfYes:(id)yesReplacement ifNo:(id)noReplacement CONVENIENCE {
    OCABridge *bridge = [[OCABridge alloc] initWithTransformer:[OCATransformer ifYes:yesReplacement ifNo:noReplacement]];
    [self addConsumer:bridge];
    return bridge;
}


- (OCABridge *)produceNegatedBoolean CONVENIENCE {
    OCABridge *bridge = [[OCABridge alloc] initWithTransformer:[OCATransformer negateBoolean]];
    [self addConsumer:bridge];
    return bridge;
}


- (OCABridge *)produceDebugLogs:(NSString *)prefix CONVENIENCE {
    NSString *debugPrefix = [NSString stringWithFormat:@"%@: %@", self.shortDescription, prefix];
    OCABridge *bridge = [[OCABridge alloc] initWithTransformer:[OCATransformer debugPrintWithPrefix:debugPrefix]];
    [self addConsumer:bridge];
    return bridge;
}




@end


