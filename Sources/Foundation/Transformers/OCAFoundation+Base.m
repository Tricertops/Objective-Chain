//
//  OCAFoundation+Base.m
//  Objective-Chain
//
//  Created by Martin Kiss on 10.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAFoundation+Base.h"





@implementation OCAFoundation





#pragma mark Transformers


+ (OCATransformer *)passes:(NSPredicate *)predicate or:(id)replacement {
    return [[OCATransformer if:predicate then:[OCATransformer pass] else:[OCATransformer replaceWith:replacement]]
            describe:[NSString stringWithFormat:@"pass if (%@) else nil", predicate]];
}


+ (OCATransformer *)negate {
    return [[OCATransformer fromClass:[NSNumber class] toClass:[NSNumber class] symetric:^NSNumber *(NSNumber *input) {
        if ( ! input) return nil;
        return @( ! input.boolValue);
    }]
            describe:@"negate"];
}


+ (OCATransformer *)test:(NSPredicate *)predicate {
    return [[OCATransformer if:predicate then:[OCATransformer replaceWith:@YES] else:[OCATransformer replaceWith:@NO]]
            describe:predicate.description];
}


+ (OCATransformer *)evaluate:(NSExpression *)expression {
    return [[OCATransformer fromClass:nil toClass:nil asymetric:^id(id input) {
        return [expression expressionValueWithObject:input context:nil];
    }]
            describe:[NSString stringWithFormat:@"evaluate “%@”", expression]];
}


+ (OCATransformer *)map:(NSDictionary *)dictionary {
    // Using classForKeyedArchiver, because __NSCFString is not very friendly class.
    Class inputClass = [OCAObject valueClassForClasses:[dictionary.allKeys valueForKey:OCAKP(NSObject, classForKeyedArchiver)]];
    Class outputClass = [OCAObject valueClassForClasses:[dictionary.allValues valueForKey:OCAKP(NSObject, classForKeyedArchiver)]];
    
    return [[OCATransformer fromClass:inputClass toClass:outputClass transform:^id(id input) {
        return [dictionary objectForKey:input];
    } reverse:^id(id input){
        return [[dictionary allKeysForObject:input] firstObject];
    }]
            describe:[NSString stringWithFormat:@"map %@ pairs from %@ to %@", @(dictionary.count), inputClass ?: @"various", outputClass ?: @"various"]
            reverse:[NSString stringWithFormat:@"map %@ pairs from %@ to %@", @(dictionary.count), outputClass ?: @"various", inputClass ?: @"various"]];
}






@end





extern NSUInteger OCANormalizeIndex(NSInteger index, NSUInteger length) {
    
    if (index < 0)
        index = length + index;
    
    if (index < 0)
        return 0;
    
    if (index >= length)
        index = length;
    
    return index;
}


extern NSRange OCANormalizeRange(NSRange range, NSUInteger length) {
    
    if (range.location > length)
        range.location = length;
    
    NSUInteger end = length - range.location;
    
    if (range.length > end)
        range.length = end;
    
    return range;
}


