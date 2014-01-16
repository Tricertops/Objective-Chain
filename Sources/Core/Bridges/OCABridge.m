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
#import "OCAConnection.h"










@implementation OCABridge





#pragma mark Creating Bridge


- (instancetype)initWithValueClass:(Class)valueClass {
    return [super initWithValueClass:valueClass];
}


+ (OCABridge *)bridge {
    return [[self alloc] initWithValueClass:nil];
}


+ (OCABridge *)bridgeForClass:(Class)class {
    return [[self alloc] initWithValueClass:class];
}





#pragma mark Lifetime of Bridge


- (Class)consumedValueClass {
    return self.valueClass;
}


- (void)consumeValue:(id)value {
    [self produceValue:value];
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





- (OCAProducer *)bridgeOnQueue:(OCAQueue *)queue {
    OCABridge *bridge = [[OCABridge alloc] initWithValueClass:self.valueClass];
    (void)[[OCAConnection alloc] initWithProducer:self queue:queue transform:nil consumer:bridge];
    return bridge;
}


- (OCAProducer *)bridgeWithTransform:(NSValueTransformer *)transformer {
    Class class = (transformer? [transformer.class transformedValueClass] : self.valueClass);
    OCABridge *bridge = [[OCABridge alloc] initWithValueClass:class];
    (void)[[OCAConnection alloc] initWithProducer:self queue:nil transform:transformer consumer:bridge];
    return bridge;
}


- (OCAConnection *)onQueue:(OCAQueue *)queue transform:(NSValueTransformer *)transformer bridge:(OCABridge *)bridge {
    return [[OCAConnection alloc] initWithProducer:self queue:queue transform:transformer consumer:bridge];
}





@end


