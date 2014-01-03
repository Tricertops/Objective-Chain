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


+ (OCATransformer *)null {
    return [[OCATransformer fromClass:nil toClass:nil symetric:OCATransformationNil] describe:@"null"];
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
            describe:[NSString stringWithFormat:@"[%@]", [descriptions componentsJoinedByString:@", "]]
            reverse:[NSString stringWithFormat:@"[%@]", [reverseDescriptions.reverseObjectEnumerator.allObjects componentsJoinedByString:@", "]]];
}


+ (OCATransformer *)convertTo:(Class)finalClass using:(NSArray *)transformers {
    NSMapTable *byInputClass = [NSMapTable strongToStrongObjectsMapTable];
    NSMapTable *byOutputClass = [NSMapTable strongToStrongObjectsMapTable];
    NSMutableSet *inputClasses = [[NSMutableSet alloc] init];
    for (OCATransformer *t in transformers) {
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
            OCATransformer *t = [byInputClass objectForKey:class];
            if (t) return [t transformedValue:input];
            class = class.superclass;
        }
        return nil; //TODO: Instantinate default transformer.
    } reverse:^id(id input) {
        // Reverse is basically undefined, but this should do it. Using first most concrete transformer.
        Class class = [input class];
        while (class) {
            OCATransformer *t = [byOutputClass objectForKey:class];
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
    OCAAssert([inputClass isSubclassOfClass:outputClass], @"") return [OCATransformer null];
    
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


+ (OCATransformer *)copy {
    return [[OCATransformer fromClass:nil toClass:nil transform:^id(id input) {
        if ([input conformsToProtocol:@protocol(NSCopying)]) return [input copy];
        else return input;
    } reverse:OCATransformationPass] describe:@"copy" reverse:@"pass"];
}


+ (OCATransformer *)mutableCopy {
    return [[OCATransformer fromClass:nil toClass:nil transform:^id(id input) {
        if ([input conformsToProtocol:@protocol(NSMutableCopying)]) return [input mutableCopy];
        else return input;
    } reverse:OCATransformationPass] describe:@"mutable copy" reverse:@"pass"];
}


+ (OCATransformer *)if:(NSPredicate *)predicate then:(OCATransformer *)thenTransformer else:(OCATransformer *)elseTransformer {
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


+ (OCATransformer *)traverseKeyPath:(NSString *)keypath {
    return [[OCATransformer fromClass:nil toClass:nil asymetric:^id(id input) {
        return [input valueForKeyPath:keypath];
    }] describe:[NSString stringWithFormat:@"key-path %@", keypath]];
}


+ (OCATransformer *)replaceWith:(id)replacement {
    return [[OCATransformer fromClass:nil toClass:[replacement class] transform:^id(id input) {
        return replacement;
    } reverse:OCATransformationPass]
            describe:[NSString stringWithFormat:@"replace with %@", replacement]];
}


+ (OCATransformer *)map:(NSDictionary *)dictionary {
    // Using classForKeyedArchiver, because __NSCFString is not very friendly class.
    Class inputClass = [OCATransformer valueClassForClasses:[dictionary.allKeys valueForKey:@"classForKeyedArchiver"]];
    Class outputClass = [OCATransformer valueClassForClasses:[dictionary.allValues valueForKey:@"classForKeyedArchiver"]];
    
    return [[OCATransformer fromClass:inputClass toClass:outputClass transform:^id(id input) {
        return [dictionary objectForKey:input];
    } reverse:^id(id input){
        return [[dictionary allKeysForObject:input] firstObject];
    }]
            describe:[NSString stringWithFormat:@"map %@ pairs from %@ to %@", @(dictionary.count), inputClass ?: @"various", outputClass ?: @"various"]
            reverse:[NSString stringWithFormat:@"map %@ pairs from %@ to %@", @(dictionary.count), outputClass ?: @"various", inputClass ?: @"various"]];
}


+ (OCATransformer *)mapFromTable:(NSMapTable *)mapTable {
    // Using classForKeyedArchiver, because __NSCFString is not very friendly class.
    Class inputClass = [OCATransformer valueClassForClasses:[mapTable.keyEnumerator.allObjects valueForKey:@"classForKeyedArchiver"]];
    Class outputClass = [OCATransformer valueClassForClasses:[mapTable.objectEnumerator.allObjects valueForKey:@"classForKeyedArchiver"]];
    
    return [[OCATransformer fromClass:inputClass toClass:outputClass transform:^id(id input) {
        return [mapTable objectForKey:input];
    } reverse:^id(id input){
        if ( ! input) return nil;
        
        for (id key in mapTable) {
            id value = [mapTable objectForKey:key];
            if ([value isEqualTo:input]) {
                return key;
            }
        }
        return nil;
    }]
            describe:[NSString stringWithFormat:@"map %@ pairs from %@ to %@", @(mapTable.count), inputClass ?: @"various", outputClass ?: @"various"]
            reverse:[NSString stringWithFormat:@"map %@ pairs from %@ to %@", @(mapTable.count), outputClass ?: @"various", inputClass ?: @"various"]];
}


+ (OCATransformer *)ofClass:(Class)class or:(id)replacement {
    Class commonClass = [replacement class];
    while (commonClass) {
        if ([class isSubclassOfClass:commonClass]) break;
        commonClass = [commonClass superclass];
    }
    
    return [[OCATransformer fromClass:nil toClass:commonClass asymetric:^id(id input) {
        return ([input isKindOfClass:class]? input : replacement);
    }] describe:[NSString stringWithFormat:@"kind of %@ or %@", class, replacement]];
}


+ (OCATransformer *)debugPrintWithMarker:(NSString *)marker {
    return [[OCATransformer fromClass:nil toClass:nil symetric:^id(id input) {
        NSLog(@"%@: %@", marker ?: @"Debug", input);
        return input;
    }] describe:[NSString stringWithFormat:@"debug print “%@”", marker]];
}






@end


