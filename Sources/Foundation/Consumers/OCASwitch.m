//
//  OCASwitch.m
//  Objective-Chain
//
//  Created by Martin Kiss on 4.2.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCASwitch.h"
#import "OCAPredicate.h"





@implementation OCASwitch



- (instancetype)initWithDictionary:(NSDictionary *)consumersByPredicates {
    self = [super init];
    if (self) {
        self->_consumersByPredicates = consumersByPredicates;
        
        NSArray *classes = [consumersByPredicates.allValues valueForKeyPath:OCAKP(OCASwitch, consumedValueClass)];
        self->_consumedValueClass = [self valueClassForClasses:classes];
    }
    return self;
}


+ (OCASwitch *)switchYes:(id<OCAConsumer>)trueConsumer no:(id<OCAConsumer>)falseConsumer {
    return [[self alloc] initWithDictionary:@{
                                              [OCAPredicate isTrue]: trueConsumer,
                                              [OCAPredicate isFalse]: falseConsumer,
                                              }];
}


+ (OCASwitch *)switchIf:(NSPredicate *)predicate then:(id<OCAConsumer>)thenConsumer else:(id<OCAConsumer>)elseConsumer {
    return [[self alloc] initWithDictionary:@{
                                              predicate: thenConsumer,
                                              [predicate negate]: elseConsumer,
                                              }];
}





- (void)consumeValue:(id)value {
    [self.consumersByPredicates enumerateKeysAndObjectsUsingBlock:^(NSPredicate *predicate, id<OCAConsumer> consumer, BOOL *stop) {
        BOOL passed = [predicate evaluateWithObject:value];
        if ( ! passed) return;
        
        id consumedValue = value; // Always new variable.
        BOOL consumedValid = [self validateObject:&consumedValue ofClass:[consumer consumedValueClass]];
        if (consumedValid) {
            [consumer consumeValue:consumedValue];
        }
    }];
}


- (void)finishConsumingWithError:(NSError *)error {
    self->_consumersByPredicates = nil;
}





@end


