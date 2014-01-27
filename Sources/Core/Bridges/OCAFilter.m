//
//  OCAFilter.m
//  Objective-Chain
//
//  Created by Martin Kiss on 16.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAFilter.h"
#import "OCAProducer+Subclass.h"
#import "OCAPredicate.h"










@implementation OCAFilter





#pragma mark Creating Filter


- (instancetype)initWithValueClass:(Class)valueClass {
    NSPredicate *predicate = [OCAPredicate predicateForClass:valueClass block:^BOOL(id object) {
        return YES; // Pass all of that class.
    }];
    return [self initWithPredicate:predicate];
}

- (instancetype)initWithPredicate:(NSPredicate *)predicate {
    self = [super initWithValueClass:nil];
    if (self) {
        self->_predicate = predicate ?: [NSPredicate predicateWithValue:YES];
    }
    return self;
}


+ (OCAFilter *)predicate:(NSPredicate *)predicate {
    return [[self alloc] initWithPredicate:predicate];
}





#pragma mark Using Filter


- (BOOL)validateObject:(id)object {
    BOOL compatible = [self isClass:[object class] compatibleWithClass:self.valueClass];
    return (compatible && [self.predicate evaluateWithObject:object]);
}





#pragma mark Filter as a Consumer


- (Class)consumedValueClass {
    return nil;
}


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










@implementation OCAProducer (OCAFilter)





- (OCAFilter *)produceFiltered:(NSPredicate *)predicate {
    NSPredicate *validatingPredicate = [OCAPredicate predicateForClass:self.valueClass predicate:predicate];
    OCAFilter *filter = [[OCAFilter alloc] initWithPredicate:validatingPredicate];
    [self addConsumer:filter];
    return filter;
}





@end


