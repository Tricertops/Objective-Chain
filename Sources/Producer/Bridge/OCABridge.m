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


- (NSString *)description {
    NSString *adjective = (self.finished? @"finished " : @"");
    return [NSString stringWithFormat:@"%@bridge for %@", adjective, self.valueClass ?: @"anything"];
}


- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@ %p; valueClass = %@; lastValue = %@; finished = %@; error = %@>", self.class, self, self.valueClass, self.lastValue, (self.finished? @"YES" : @"NO"), self.error];
}






@end










@implementation OCAProducer (OCABridge)





- (OCABridge *)bridgeWithFilter:(NSPredicate *)filter {
    return [self bridgeWithFilter:filter transform:nil];
}


- (OCABridge *)bridgeWithTransform:(NSValueTransformer *)transformer {
    return [self bridgeWithFilter:nil transform:transformer];
}


- (OCABridge *)bridgeWithFilter:(NSPredicate *)filter transform:(NSValueTransformer *)transformer {
    Class class = (transformer? [transformer.class valueClass] : self.valueClass);
    OCABridge *bridge = [OCABridge bridgeForClass:class];
    [self connectWithFilter:filter transform:transformer to:bridge];
    return bridge;
}





@end


