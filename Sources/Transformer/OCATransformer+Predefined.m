//
//  OCATransformer+Predefined.m
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer+Predefined.h"





@implementation OCATransformer (Predefined)





#pragma mark Basic


+ (OCATransformer *)pass {
    return [[OCATransformer fromClass:nil toClass:nil symetric:OCATransformationPass]
            describe:@"pass"];
}


+ (OCATransformer *)null {
    return [[OCATransformer fromClass:nil toClass:nil symetric:OCATransformationNil]
            describe:@"nil"];
}


+ (OCATransformer *)replaceWith:(id)replacement {
    return [[OCATransformer fromClass:nil toClass:[replacement classForKeyedArchiver] transform:^id(id input) {
        return replacement;
    } reverse:OCATransformationPass]
            describe:[NSString stringWithFormat:@"replace with %@", replacement]];
}


+ (OCATransformer *)ifNull:(id)replacement {
    OCAAssert(replacement != nil, @"Are you kidding me?");
    
    return [[OCATransformer fromClass:nil toClass:nil transform:^id(id input) {
        return input ?: replacement;
    } reverse:OCATransformationPass]
            describe:[NSString stringWithFormat:@"replace nil by %@", replacement]];
}


+ (OCATransformer *)kindOfClass:(Class)class or:(id)replacement {
    Class commonClass = [replacement classForKeyedArchiver];
    while (commonClass) {
        if ([class isSubclassOfClass:commonClass]) break;
        commonClass = [commonClass superclass];
    }
    
    return [[OCATransformer fromClass:nil toClass:commonClass asymetric:^id(id input) {
        return ( ! input || [input isKindOfClass:class]? input : replacement);
    }] describe:[NSString stringWithFormat:@"kind of %@ or %@", class, replacement]];
}


+ (OCATransformer *)passes:(NSPredicate *)predicate or:(id)replacement {
    return [[OCATransformer if:predicate then:[OCATransformer pass] else:[OCATransformer replaceWith:replacement]]
            describe:[NSString stringWithFormat:@"pass if (%@) else nil", predicate]];
}


+ (OCATransformer *)test:(NSPredicate *)predicate {
    return [[OCATransformer if:predicate then:[OCATransformer replaceWith:@YES] else:[OCATransformer replaceWith:@NO]]
            describe:predicate.description];
}


+ (OCATransformer *)not {
    return [[OCATransformer fromClass:[NSNumber class] toClass:[NSNumber class] symetric:^NSNumber *(NSNumber *input) {
        if ( ! input) return nil;
        return @( ! input.boolValue);
    }]
            describe:@"not"];
}


+ (OCATransformer *)count {
    return [[OCATransformer fromClass:nil toClass:[NSNumber class] asymetric:^id(id input) {
        if ([input respondsToSelector:@selector(count)]) return @([input count]);
        else return nil;
    }] describe:@"count"];
}


+ (OCATransformer *)map:(NSDictionary *)dictionary {
    // Using classForKeyedArchiver, because __NSCFString is not very friendly class.
    Class inputClass = [OCATransformer valueClassForClasses:[dictionary.allKeys valueForKey:OCAKeypathUnsafe(classForKeyedArchiver)]];
    Class outputClass = [OCATransformer valueClassForClasses:[dictionary.allValues valueForKey:OCAKeypathUnsafe(classForKeyedArchiver)]];
    
    return [[OCATransformer fromClass:inputClass toClass:outputClass transform:^id(id input) {
        return [dictionary objectForKey:input];
    } reverse:^id(id input){
        return [[dictionary allKeysForObject:input] firstObject];
    }]
            describe:[NSString stringWithFormat:@"map %@ pairs from %@ to %@", @(dictionary.count), inputClass ?: @"various", outputClass ?: @"various"]
            reverse:[NSString stringWithFormat:@"map %@ pairs from %@ to %@", @(dictionary.count), outputClass ?: @"various", inputClass ?: @"various"]];
}






#pragma mark Control Flow


+ (OCATransformer *)sequence:(NSArray *)transformers {
    if ( ! transformers.count) return [self pass];
    transformers = [transformers copy];
    
    NSValueTransformer *firstTransformer = transformers.firstObject;
    NSValueTransformer *lastTransformer = transformers.lastObject;
    
    BOOL areReversible = YES;
    NSMutableArray *descriptions = [[NSMutableArray alloc] init];
    NSMutableArray *reverseDescriptions = [[NSMutableArray alloc] init];
    
    Class previousOutputClass = nil;
    for (NSValueTransformer *t in transformers) {
        areReversible &= [t.class allowsReverseTransformation];
        [descriptions addObject:t.description ?: @"unknown"];
        [reverseDescriptions addObject:t.reversed.description ?: @"unknown"];
        
        OCAAssert(previousOutputClass == Nil || [t.class valueClass] == Nil || [[t.class valueClass] isSubclassOfClass:previousOutputClass], @"Classes of transformers in sequence are incompatible.") return [OCATransformer null];
        previousOutputClass = [t.class transformedValueClass];
    }
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
            describe:[NSString stringWithFormat:@"[%@]", [descriptions componentsJoinedByString:@", "]]
            reverse:[NSString stringWithFormat:@"[%@]", [reverseDescriptions.reverseObjectEnumerator.allObjects componentsJoinedByString:@", "]]];
}


+ (OCATransformer *)convertTo:(Class)finalClass using:(NSArray *)transformers {
    NSMapTable *byInputClass = [NSMapTable strongToStrongObjectsMapTable];
    NSMapTable *byOutputClass = [NSMapTable strongToStrongObjectsMapTable];
    NSMutableSet *inputClasses = [[NSMutableSet alloc] init];
    for (NSValueTransformer *t in transformers) {
        //TODO: Warn about multiple matches.
        Class inputClass = [t.class valueClass] ?: [NSObject class];
        Class outputClass = [t.class transformedValueClass] ?: [NSObject class];
        [byInputClass setObject:t forKey:inputClass];
        [byOutputClass setObject:t forKey:outputClass];
        [inputClasses addObject:inputClass];
        
        OCAAssert([outputClass isSubclassOfClass:finalClass], @"Provided transformer doesn't have requested output class.");
    }
    NSString *inputClassesString = [inputClasses.allObjects componentsJoinedByString:@", "];
    
    //TODO: Find common input class.
    return [[OCATransformer fromClass:nil toClass:finalClass transform:^id(id input) {
        Class class = [input class];
        while (class) {
            NSValueTransformer *t = [byInputClass objectForKey:class];
            if (t) return [t transformedValue:input];
            class = class.superclass;
        }
        return nil; //TODO: Instantinate default transformer.
    } reverse:^id(id input) {
        // Reverse is basically undefined, but this should do it. Using first most concrete transformer.
        Class class = [input class];
        while (class) {
            NSValueTransformer *t = [byOutputClass objectForKey:class];
            if (t) return [t reverseTransformedValue:input];
            class = class.superclass;
        }
        return input; // Lookup failed, pass.
    }]
            describe:[NSString stringWithFormat:@"convert { %@ } to %@", inputClassesString, finalClass]
            reverse:[NSString stringWithFormat:@"convert %@ to undefined { %@ }", finalClass, inputClassesString]];
}


+ (OCATransformer *)repeat:(NSUInteger)count transformer:(NSValueTransformer *)transformer {
    Class inputClass = [transformer.class valueClass];
    Class outputClass = [transformer.class transformedValueClass];
    OCAAssert(inputClass == Nil || outputClass == Nil || [inputClass isSubclassOfClass:outputClass], @"Transformer cannot be repeated.") return [OCATransformer null];
    
    return [[OCATransformer fromClass:inputClass toClass:outputClass transform:^id(id input) {
        id value = input;
        for (NSUInteger iteration = 0; iteration < count; iteration++) {
            value = [transformer transformedValue:value];
        }
        return value;
    } reverse:^id(id input) {
        id value = input;
        for (NSUInteger iteration = 0; iteration < count; iteration++) {
            value = [transformer reverseTransformedValue:value];
        }
        return value;
    }]
            describe:[NSString stringWithFormat:@"%@ times %@", @(count), transformer]
            reverse:[NSString stringWithFormat:@"%@ times %@", @(count), [transformer reversed]]];
}


+ (OCATransformer *)if:(NSPredicate *)predicate then:(NSValueTransformer *)thenTransformer else:(NSValueTransformer *)elseTransformer {
    Class inputClass = [self valueClassForClasses:@[ [thenTransformer.class valueClass],
                                                     [elseTransformer.class valueClass] ]];
    Class outputClass = [self valueClassForClasses:@[ [thenTransformer.class transformedValueClass],
                                                      [elseTransformer.class transformedValueClass] ]];
    
    return [[OCATransformer fromClass:inputClass toClass:outputClass asymetric:^id(id input) {
        BOOL condition = ( ! predicate || [predicate evaluateWithObject:input]);
        if (condition)
            return [thenTransformer transformedValue:input];
        else
            return (elseTransformer ? [elseTransformer transformedValue:input] : input);
    }] describe:[NSString stringWithFormat:@"if (%@) then %@ else %@", predicate, thenTransformer, elseTransformer ?: @"pass"]];
}





#pragma mark Key-Value Coding


+ (OCATransformer *)accessKeyPath:(NSString *)keypath {
    return [[OCATransformer fromClass:nil toClass:nil asymetric:^id(id input) {
        return [input valueForKeyPath:keypath];
    }] describe:[NSString stringWithFormat:@".%@", keypath]];
}


+ (OCATransformer *)modifyKeyPath:(NSString *)keypath value:(id)value {
    return [[OCATransformer sideEffect:^(id input) {
        [input setValue:value forKeyPath:keypath];
    }] describe:[NSString stringWithFormat:@".%@ = %@", keypath, value]];
}


+ (OCATransformer *)transformKeyPath:(NSString *)keypath transformer:(NSValueTransformer *)transformer {
    Class inputClass = [transformer.class valueClass];
    Class outputClass = [transformer.class transformedValueClass];
    OCAAssert(inputClass == Nil || outputClass == Nil || [outputClass isSubclassOfClass:inputClass], @"Transformer should return what he gets.") return [OCATransformer null];
    
    return [[OCATransformer fromClass:nil toClass:nil transform:^id(id input) {
        if ( ! input) return nil;
        
        id value = [input valueForKeyPath:keypath];
        value = [transformer transformedValue:value];
        [input setValue:value forKeyPath:keypath];
        
        return input;
    } reverse:^id(id input) {
        if ( ! input) return nil;
        
        id value = [input valueForKeyPath:keypath];
        value = [transformer reverseTransformedValue:value];
        [input setValue:value forKeyPath:keypath];
        
        return input;
    }]
            describe:[NSString stringWithFormat:@"transform .%@ using %@", keypath, transformer]
            reverse:[NSString stringWithFormat:@"transform .%@ using %@", keypath, [transformer reversed]]];
}





#pragma mark Struct Accessors


+ (OCATransformer *)accessStruct:(OCAStructureAccessor *)structAccessor {
    return [[OCATransformer fromClass:[NSValue class]
                             toClass:(structAccessor.isNumeric? [NSNumber class] : [NSValue class])
                           asymetric:^NSValue *(NSValue *input) {
                               return [structAccessor memberFromStructure:input];
                           }] describe:structAccessor.description];
}


+ (OCATransformer *)modifyStruct:(OCAStructureAccessor *)structAccessor value:(NSValue *)memberValue {
    return [[OCATransformer fromClass:[NSValue class] toClass:[NSValue class] symetric:^NSValue *(NSValue *structValue) {
        return [structAccessor setMember:memberValue toStructure:structValue];
    }] describe:[NSString stringWithFormat:@"%@ = %@", structAccessor, memberValue]];
}





#pragma mark Side Effects


+ (OCATransformer *)sideEffect:(void(^)(id value))block {
    return [[OCATransformer fromClass:nil toClass:nil symetric:^id(id input) {
        if (block) block(input);
        return input;
    }] describe:@"[side effect]"];
}


+ (OCATransformer *)debugPrintWithMarker:(NSString *)marker {
    return [[OCATransformer sideEffect:^(id value) {
        NSLog(@"%@: %@", marker ?: @"Debug", value);
    }] describe:[NSString stringWithFormat:@"[debug print “%@”]", marker]];
}






@end


