//
//  OCATransformer+Foundation.m
//  Objective-Chain
//
//  Created by Martin Kiss on 4.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer+Foundation.h"










@implementation OCAFoundation





#pragma mark NSArray


+ (OCATransformer *)branchArray:(NSArray *)transformers {
    return [OCATransformer fromClass:nil toClass:[NSArray class] asymetric:^NSArray *(id input) {
        NSMutableArray *output = [[NSMutableArray alloc] init];
        
        for (NSValueTransformer *t in transformers) {
            id transformed = [t transformedValue:input];
            [output addObject:transformed];
        }
        
        return output;
    }];
}


+ (OCATransformer *)wrapInArray {
    return [[OCATransformer fromClass:nil toClass:[NSArray class] transform:^NSArray *(id input) {
        return (input? @[ input ] : nil);
    } reverse:^id(NSArray *input) {
        return [input firstObject];
    }]
            describe:@"wrap"
            reverse:@"first object"];
}


+ (OCATransformer *)arrayFromFile {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSArray class] asymetric:^NSArray *(NSString *input) {
        return (input.length? [NSArray arrayWithContentsOfFile:input] : nil);
    }]
            describe:@"array from file"];
}





@end




