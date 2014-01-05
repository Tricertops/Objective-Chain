//
//  OCABridge.m
//  Objective-Chain
//
//  Created by Martin Kiss on 5.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCABridge.h"
#import "OCAProducer+Private.h"










@implementation OCABridge





#pragma mark Creating Bridge


- (instancetype)init {
    return [super init];
}


+ (instancetype)bridge {
    return [[self alloc] init];
}





#pragma mark Lifetime of Bridge


- (void)consumeValue:(id)value {
    [self produceValue:value];
}


- (void)finishConsumingWithError:(NSError *)error {
    [self finishProducingWithError:error];
}





@end


