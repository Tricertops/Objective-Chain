//
//  OCATransformer+Predefined.m
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer+Predefined.h"





@implementation OCATransformer (Predefined)





+ (OCATransformer *)pass {
    return [[OCATransformer fromClass:nil toClass:nil symetric:OCATransformationPass] describe:@"pass"];
}


+ (OCATransformer *)sequence:(NSArray *)transformers {
    if ( ! transformers.count) return [self pass];
    transformers = [transformers copy];
    
    OCATransformer *firstTransformer = transformers.firstObject;
    OCATransformer *lastTransformer = transformers.lastObject;
    
    BOOL areReversible = YES;
    NSMutableArray *descriptions = [[NSMutableArray alloc] init];
    NSMutableArray *reverseDescriptions = [[NSMutableArray alloc] init];
    
    for (OCATransformer *t in transformers) {
        areReversible &= [t.class allowsReverseTransformation];
        [descriptions addObject:t.description ?: @"unknown"];
        [reverseDescriptions addObject:t.reverseDescription ?: @"unknown"];
    }
    //TODO: Class check
    
    return [[OCATransformer fromClass:[firstTransformer.class valueClass]
                              toClass:[lastTransformer.class transformedValueClass]
                            transform:^id(id input) {
                                id value = input;
                                for (NSValueTransformer *t in transformers) {
                                    value = [t transformedValue:value];
                                }
                                return value;
                            } reverse:^id(id input) {
                                id value = input;
                                for (NSValueTransformer *t in transformers.reverseObjectEnumerator.allObjects) {
                                    value = [t reverseTransformedValue:value];
                                }
                                return value;
                            }]
            describe:[NSString stringWithFormat:@"(%@)", [descriptions componentsJoinedByString:@" –> "]]
            reverse:[NSString stringWithFormat:@"(%@)", [reverseDescriptions.reverseObjectEnumerator.allObjects componentsJoinedByString:@" –> "]]];
}





@end


