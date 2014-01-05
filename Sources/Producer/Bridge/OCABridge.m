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


+ (instancetype)bridge {
    return [[self alloc] init];
}


+ (instancetype)bridgeForClass:(Class)class {
    return [[self alloc] initWithValueClass:class];
}





#pragma mark Lifetime of Bridge


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


