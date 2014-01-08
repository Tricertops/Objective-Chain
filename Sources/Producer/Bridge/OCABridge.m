//
//  OCABridge.m
//  Objective-Chain
//
//  Created by Martin Kiss on 5.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCABridge.h"
#import "OCAProducer+Private.h"
#import "OCATransformer.h"










@implementation OCABridge





#pragma mark Creating Bridge


+ (instancetype)bridge {
    return [[self alloc] init];
}


+ (instancetype)bridgeForClass:(Class)class {
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





- (OCAProducer *)bridgeOn:(OCAQueue *)queue {
    return [self bridgeOn:queue filter:nil transform:nil];
}


- (OCAProducer *)bridgeWithFilter:(NSPredicate *)filter transform:(NSValueTransformer *)transformer {
    return [self bridgeOn:nil filter:filter transform:transformer];
}


- (OCAProducer *)bridgeOn:(OCAQueue *)queue filter:(NSPredicate *)filter transform:(NSValueTransformer *)transformer {
    Class class = (transformer? [transformer.class valueClass] : self.valueClass);
    OCABridge *bridge = [OCABridge bridgeForClass:class];
    [self connectOn:queue filter:filter transform:transformer to:bridge];
    return bridge;
}





@end


