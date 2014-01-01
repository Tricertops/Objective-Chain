//
//  OCATransformer+Predefined.m
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer+Predefined.h"





@implementation OCATransformer (Predefined)





+ (instancetype)pass {
    Class class = [self subclassForInputClass:nil outputClass:nil reversible:YES name:@"OCAPassTransformer"];
    return [[class alloc] initWithBlock:nil reverseBlock:nil];
}


+ (instancetype)sequence:(NSArray *)transformers {
    if ( ! transformers.count) return [self pass];
    transformers = [transformers copy];
    
    NSValueTransformer *firstTransformer = transformers.firstObject;
    NSValueTransformer *lastTransformer = transformers.lastObject;
    
    BOOL areReversible = YES;
    for (NSValueTransformer *t in transformers) {
        if ( ! [t.class allowsReverseTransformation]) {
            areReversible = NO;
            break;
        }
    }
    
    Class class = [self subclassForInputClass:[firstTransformer.class valueClass]
                                  outputClass:[lastTransformer.class transformedValueClass]
                                   reversible:areReversible
                                         name:nil];
    
    return [[class alloc] initWithBlock:^id(id input) {
        id value = input;
        for (NSValueTransformer *t in transformers) {
            value = [t transformedValue:value];
        }
        return value;
    } reverseBlock:^id(id input) {
        id value = input;
        for (NSValueTransformer *t in transformers.reverseObjectEnumerator.allObjects) {
            value = [t reverseTransformedValue:value];
        }
        return value;
    }];
}





@end


