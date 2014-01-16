//
//  OCAFilter.m
//  Objective-Chain
//
//  Created by Martin Kiss on 16.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAFilter.h"
#import "OCAProducer+Subclass.h"










@implementation OCAFilter





#pragma mark Creating Filter

- (instancetype)initWithValueClass:(Class)valueClass predicate:(NSPredicate *)predicate {
    self = [super init];
    if (self) {
        self->_predicate = nil ?: [NSPredicate predicateWithValue:YES];
    }
    return self;
}


+ (OCAFilter *)evaluate:(NSPredicate *)predicate {
    return [[self alloc] initWithValueClass:nil predicate:predicate];
}





#pragma mark Using Filter


- (BOOL)validateObject:(id)object {
    BOOL compatible = [self isClass:[object class] compatibleWithClass:self.valueClass];
    return (compatible && [self.predicate evaluateWithObject:object]);
}





#pragma mark Filter as a Consumer


- (void)consumeValue:(id)value {
    if ([self validateObject:value]) {
        [self produceValue:value];
    }
}


- (void)finishConsumingWithError:(NSError *)error {
    [self finishProducingWithError:error];
}





#pragma mark Describing Filter


- (NSString *)descriptionName {
    return @"Filter";
}


- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@", self.shortDescription, self.predicate];
}


- (NSDictionary *)debugDescriptionValues {
    return @{
             @"predicate": self.predicate ?: @"nil",
             };
}





@end


