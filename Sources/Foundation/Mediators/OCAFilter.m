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


+ (OCAFilter *)filterWithPredicate:(NSPredicate *)predicate {
    return [[self alloc] initWithPredicate:predicate];
}


+ (OCAFilter *)filterThatSkipsFirst:(NSUInteger)countToSkip {
    // This instance uses __block variable that outlives the block scope.
    __block NSUInteger countOfValues = 0;
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        countOfValues ++;
        return (countOfValues > countToSkip);
    }];
    return [[self alloc] initWithPredicate:predicate];
}


+ (OCAFilter *)filterThatSkipsEqual {
    // This instance uses __block variable that outlives the block scope.
    __block id previouslyEvaluatedObject = nil; //TODO: Don't retain the previous forever. Maybe class and hash comparision would be enough.
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        BOOL isEqual = OCAEqual(previouslyEvaluatedObject, evaluatedObject);
        previouslyEvaluatedObject = evaluatedObject;
        return ! isEqual;
    }];
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





@end


