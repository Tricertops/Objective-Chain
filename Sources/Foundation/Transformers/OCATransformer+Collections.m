//
//  OCATransformer+Collections.m
//  Objective-Chain
//
//  Created by Martin Kiss on 10.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer+Collections.h"
#import "NSArray+Ordinals.h"
#import "NSValue+Boxing.h"





@implementation OCATransformer (Collections)





+ (OCATransformer *)countCollection {
    return [[OCATransformer fromClass:nil toClass:[NSNumber class]
                            asymetric:^id(id input) {
                                
                                if ([input respondsToSelector:@selector(count)]) return @([input count]);
                                else return nil;
                                
                            }]
            describe:@"count"];
}


+ (OCATransformer *)objectForKey:(id)key {
    return [[OCATransformer fromClass:nil toClass:nil
                            asymetric:^id(id input) {
                                
                                if ([input respondsToSelector:@selector(objectForKey:)]) {
                                    return [input objectForKey:key];
                                }
                                return nil;
                            }]
            describe:[NSString stringWithFormat:@"object for key “%@”", key]];
}






#pragma mark -
#pragma mark NSArray
#pragma mark -


#pragma mark NSArray - Create


+ (OCATransformer *)branchArray:(NSArray *)transformers {
    return [[OCATransformer fromClass:nil toClass:[NSArray class]
                            asymetric:^NSArray *(id input) {
                                
                                NSMutableArray *output = [[NSMutableArray alloc] init];
                                for (NSValueTransformer *t in transformers) {
                                    id transformed = [t transformedValue:input];
                                    [output addObject:transformed ?: [NSNull null]];
                                }
                                return output;
                            }]
            describe:[NSString stringWithFormat:@"branch { %@ }", [transformers componentsJoinedByString:@", "]]];
}


+ (OCATransformer *)wrapInArray {
    return [[OCATransformer fromClass:nil toClass:[NSArray class]
                            transform:^NSArray *(id input) {
                                
                                return (input? @[ input ] : nil);
                                
                            } reverse:^id(NSArray *input) {
                                
                                return [input firstObject];
                            }]
            describe:@"wrap"
            reverse:@"first object"];
}


+ (OCATransformer *)arrayFromFile {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSArray class]
                            asymetric:^NSArray *(NSString *input) {
                                
                                return [NSArray arrayWithContentsOfFile:input];
                            }]
            describe:@"array from file"];
}





#pragma mark NSArray - Subarray


+ (OCATransformer *)objectsAtIndexes:(NSIndexSet *)indexes {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSArray class]
                            transform:^NSArray *(NSArray *input) {
                                
                                NSIndexSet *safeIndexes = [indexes indexesPassingTest:^BOOL(NSUInteger index, BOOL *stop) {
                                    return (index < [input count]);
                                }];
                                return [input objectsAtIndexes:safeIndexes];
                                
                            } reverse:OCATransformationPass]
            
            describe:[NSString stringWithFormat:@"objects at indexes %@", indexes]
            reverse:@"pass"];
}



+ (OCATransformer *)subarrayToIndex:(NSInteger)index {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSArray class]
                            transform:^NSArray *(NSArray *input) {
        
                                NSUInteger realIndex = OCANormalizeIndex(index, input.count);
                                return [input subarrayWithRange:NSMakeRange(0, realIndex)];
                                
                            } reverse:OCATransformationPass]
            describe:[NSString stringWithFormat:@"subarray to index %@", @(index)]
            reverse:@"pass"];
}


+ (OCATransformer *)subarrayFromIndex:(NSInteger)index {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSArray class]
                            transform:^NSArray *(NSArray *input) {
                                
                                NSInteger realIndex = OCANormalizeIndex(index, input.count);
                                return [input subarrayWithRange:NSMakeRange(realIndex, input.count - realIndex)];
                                
                            } reverse:OCATransformationPass]
            
            describe:[NSString stringWithFormat:@"subarray from index %@", @(index)]
            reverse:@"pass"];
}


+ (OCATransformer *)subarrayWithRange:(NSRange)range {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSArray class]
                            transform:^NSArray *(NSArray *input) {
                                
                                return [input subarrayWithRange:OCANormalizeRange(range, input.count)];
                                
                            } reverse:OCATransformationPass]
            
            describe:[NSString stringWithFormat:@"subarray with range %@", NSStringFromRange(range)]
            reverse:@"pass"];
}





#pragma mark NSArray - Alter


+ (NSArray *)transformArray:(NSArray *)array transformer:(NSValueTransformer *)transformer {
    NSMutableArray *mutable = [[NSMutableArray alloc] init];
    for (id object in array) {
        id transformed = [transformer transformedValue:object];
        [mutable addObject:transformed ?: [NSNull null]];
    }
    return mutable;
}


+ (OCATransformer *)transformArray:(NSValueTransformer *)transformer {
    NSValueTransformer *reversedTransformer = [transformer reversed];
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSArray class]
                            transform:^NSArray *(NSArray *input) {
                                
                                return [self transformArray:input transformer:transformer];
                                
                            } reverse:^NSArray *(NSArray *input) {
                                
                                return [self transformArray:input transformer:reversedTransformer];
                            }]
            describe:[NSString stringWithFormat:@"for each %@", transformer]
            reverse:[NSString stringWithFormat:@"for each %@", reversedTransformer]];
}


+ (OCATransformer *)filterArray:(NSPredicate *)predicate {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSArray class]
                             symetric:^NSArray *(NSArray *input) {
                                 
                                 return [input filteredArrayUsingPredicate:predicate];
                             }]
            describe:[NSString stringWithFormat:@"filter %@", predicate]];
}


+ (OCATransformer *)sortArray:(NSArray *)sortDescriptors {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSArray class]
                             symetric:^NSArray *(NSArray *input) {
                                 
                                 return [input sortedArrayUsingDescriptors:sortDescriptors];
                             }]
            describe:[NSString stringWithFormat:@"sort by (%@)", [sortDescriptors componentsJoinedByString:@", "]]];
}


+ (OCATransformer *)flattenArrayRecursively:(BOOL)recursively {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSArray class]
                            asymetric:^id(id input) {
                                
                                NSMutableArray *output = [[NSMutableArray alloc] init];
                                NSMutableArray *stack = [NSMutableArray arrayWithArray:input];
                                
                                while (stack.count) {
                                    id object = [stack objectAtIndex:0];
                                    [stack removeObjectAtIndex:0];
                                    
                                    BOOL isSubarray = [object isKindOfClass:[NSArray class]];
                                    if ( ! isSubarray) {
                                        [output addObject:object];
                                        continue;
                                    }
                                    else {
                                        NSArray *subarray = (NSArray *)object;
                                        if (recursively) {
                                            NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, subarray.count)];
                                            [stack insertObjects:subarray atIndexes:indexes];
                                        }
                                        else {
                                            [output addObjectsFromArray:subarray];
                                        }
                                    }
                                }
                                
                                return output;
                            }]
            describe:(recursively? @"flatten recursively" : @"flatten")];
}


+ (OCATransformer *)randomizeArray {
    return [[OCATransformer mutateArray:^(NSMutableArray *array) {
        for (NSUInteger sourceIndex = 1; sourceIndex < array.count; sourceIndex++) {
            
            NSUInteger destinationRange = array.count - sourceIndex;
            NSUInteger destinationIndex = arc4random_uniform((u_int32_t)destinationRange + 1);
            
            [array exchangeObjectAtIndex:sourceIndex withObjectAtIndex:destinationIndex];
        }
    }]
            describe:@"randomize order"];
}


+ (OCATransformer *)removeNullsFromArray {
    return [[OCATransformer mutateArray:^(NSMutableArray *array) {
        [array removeObjectIdenticalTo:[NSNull null]];
    }]
            describe:@"remove nulls"];
}


+ (OCATransformer *)mutateArray:(void(^)(NSMutableArray *array))block {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSArray class]
                            asymetric:^NSArray *(NSArray *input) {
                                NSMutableArray *output = [NSMutableArray arrayWithArray:input];
                                block(output);
                                return output;
                            }]
            describe:@"mutate array"];
}





#pragma mark NSArray - Dispose


+ (OCATransformer *)objectAtIndex:(NSInteger)index {
    return [[OCATransformer fromClass:[NSArray class] toClass:nil
                            asymetric:^id(NSArray *input) {
                                
                                return [input oca_valueAtIndex:index];
                            }]
            describe:[NSString stringWithFormat:@"index %@", @(index)]];
}


+ (OCATransformer *)joinWithString:(NSString *)string {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSString class]
                            transform:^NSString *(NSArray *input) {
                                //TODO: Ignore NSNull
                                return [input componentsJoinedByString:string];
                                
                            } reverse:^NSArray *(NSString *input) {
                                
                                return [input componentsSeparatedByString:string];
                            }]
            describe:[NSString stringWithFormat:@"join with “%@”", string]
            reverse:[NSString stringWithFormat:@"split by “%@”", string]];
}


+ (OCATransformer *)joinWithAttributedString:(NSAttributedString *)attrString {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSAttributedString class]
                            transform:^NSAttributedString *(NSArray *input) {
                                
                                NSMutableAttributedString *mutable = [[NSMutableAttributedString alloc] init];
                                [input enumerateObjectsUsingBlock:^(NSAttributedString *component, NSUInteger index, BOOL *stop) {
                                    if (index != 0 && attrString) {
                                        [mutable appendAttributedString:attrString];
                                    }
                                    if ( ! [component isKindOfClass:[NSAttributedString class]]) {
                                        component = [[NSAttributedString alloc] initWithString:component.description];
                                    }
                                    [mutable appendAttributedString:component];
                                }];
                                
                                return mutable;
                                
                            } reverse:OCATransformationDiscard]
            describe:[NSString stringWithFormat:@"join with “%@”", attrString.string]];
}


+ (OCATransformer *)joinWithString:(NSString *)string last:(NSString *)lastString {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSString class]
                            asymetric:^NSString *(NSArray *input) {
                                if (input.count > 1) {
                                    NSArray *inputWithoutLast = [input subarrayWithRange:NSMakeRange(0, input.count - 1)];
                                    return [NSString stringWithFormat:@"%@%@%@", [inputWithoutLast componentsJoinedByString:string], lastString, input.lastObject];
                                }
                                else {
                                    return [input componentsJoinedByString:lastString];
                                }
                            }]
            describe:[NSString stringWithFormat:@"join “%@” last “%@”", string, lastString]];
}


+ (OCATransformer *)objectFromArray:(NSArray *)objects {
    return [[OCATransformer fromClass:[NSNumber class] toClass:nil
                           transform:^id(NSNumber *input) {
                               
                               return [objects oca_valueAtIndex:input.integerValue];
                               
                           } reverse:^NSNumber *(id input) {
                               
                               return @([objects indexOfObject:input]);
                           }]
            describe:[NSString stringWithFormat:@"object from {%@}", [objects componentsJoinedByString:@", "]]
            reverse:[NSString stringWithFormat:@"index in {%@}", [objects componentsJoinedByString:@", "]]];
}


+ (OCATransformer *)indexInArray:(NSArray *)objects {
    return [[OCATransformer objectFromArray:objects] reversed];
}





#pragma mark -
#pragma mark NSDictionary
#pragma mark -


#pragma mark NSDictionary - Create


+ (OCATransformer *)dictionaryFromFile {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSDictionary class]
                           asymetric:^NSDictionary *(NSString *input) {
                               
                               return [NSDictionary dictionaryWithContentsOfFile:input];
                           }]
            describe:@"dictionary from file"];
}


+ (OCATransformer *)mappedArray:(NSValueTransformer *)transformer {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSDictionary class]
                           asymetric:^NSDictionary *(NSArray *input) {
                               
                               NSMutableDictionary *output = [[NSMutableDictionary alloc] init];
                               for (id object in input) {
                                   id transformed = [transformer transformedValue:object];
                                   if (transformed) {
                                       [output setObject:transformed forKey:object];
                                   }
                               }
                               return output;
                           }]
            describe:[NSString stringWithFormat:@"mapped array using %@", transformer]];
}


+ (OCATransformer *)keyedArray:(NSArray *)keysArray {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSDictionary class]
                           asymetric:^NSDictionary *(NSArray *input) {
                               
                               NSMutableDictionary *output = [[NSMutableDictionary alloc] init];
                               NSUInteger index = 0;
                               for (id key in keysArray) {
                                   id value = [input oca_valueAtIndex:index];
                                   if (value) {
                                       [output setObject:value forKey:key];
                                   }
                                   index++;
                               }
                               return output;
                           }]
            describe:[NSString stringWithFormat:@"keyed array {%@}", [keysArray componentsJoinedByString:@", "]]];
}


+ (OCATransformer *)mergeDictionaries {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSDictionary class]
                            asymetric:^NSDictionary *(NSArray *input) {
                                
                                NSMutableDictionary *output = [[NSMutableDictionary alloc] init];
                                for (NSDictionary *dictionary in input) {
                                    [output addEntriesFromDictionary:dictionary];
                                }
                                return output;
                            }]
            describe:@"merge dictionaries"];
}





#pragma mark NSDictionary - Alter


+ (OCATransformer *)filteredDictionary:(NSPredicate *)predicate {
    return [[OCATransformer fromClass:[NSDictionary class] toClass:[NSDictionary class]
                            transform:^NSDictionary *(NSDictionary *input) {
                                
                                NSSet *keySet = [input keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
                                    return [predicate evaluateWithObject:obj];
                                }];
                                NSArray *keys = keySet.allObjects;
                                NSArray *values = [input objectsForKeys:keys notFoundMarker:NSNull.null];
                                
                                return [NSDictionary dictionaryWithObjects:values forKeys:keys];
                                
                            } reverse:OCATransformationPass]
            
            describe:[NSString stringWithFormat:@"filter dictionary (%@)", predicate]];
}


+ (NSDictionary *)transformDictionary:(NSDictionary *)dictionary transformer:(NSValueTransformer *)transformer {
    NSMutableDictionary *mutable = [[NSMutableDictionary alloc] init];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id transformed = [transformer transformedValue:obj];
        if (transformed) {
            [mutable setObject:transformed forKey:key];
        }
    }];
    return mutable;
}


+ (OCATransformer *)transformValues:(NSValueTransformer *)transformer {
    NSValueTransformer *reversedTransformer = transformer.reversed;
    return [[OCATransformer fromClass:[NSDictionary class] toClass:[NSDictionary class]
                            transform:^NSDictionary *(NSDictionary *input) {
                                
                                return [self transformDictionary:input transformer:transformer];
                                
                            } reverse:^NSDictionary *(NSDictionary *input) {
                                
                                return [self transformDictionary:input transformer:reversedTransformer];
                            }]
            describe:[NSString stringWithFormat:@"transform dictionary %@", transformer]
            reverse:[NSString stringWithFormat:@"transform dictionary %@", reversedTransformer]];
}


+ (OCATransformer *)mutateDictionary:(void(^)(NSMutableDictionary *dictionary))block {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSDictionary class]
                            asymetric:^NSDictionary *(NSArray *input) {
                                
                                NSMutableDictionary *mutable = [input mutableCopy];
                                block(mutable);
                                return mutable;
                            }]
            describe:@"mutate dictionary"];
}





#pragma mark NSDictionary - Dispose


+ (OCATransformer *)joinPairs:(NSString *)string {
    return [[OCATransformer fromClass:[NSDictionary class] toClass:[NSArray class]
                           asymetric:^NSArray *(NSDictionary *input) {
                               
                               NSMutableArray *output = [[NSMutableArray alloc] init];
                               [input enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                                   NSString *pair = [NSString stringWithFormat:@"%@%@%@", key, string, obj];
                                   [output addObject:pair];
                               }];
                               return output;
                           }]
            describe:[NSString stringWithFormat:@"join pairs with “%@”", string]];
}


+ (OCATransformer *)keysForValue:(id)value {
    return [[OCATransformer fromClass:[NSDictionary class] toClass:[NSArray class]
                            asymetric:^NSArray *(NSDictionary *input) {
                                
                                return [input allKeysForObject:value];
                            }]
            describe:[NSString stringWithFormat:@"keys for value “%@”", value]];
}





#pragma mark -
#pragma mark NSIndexSet
#pragma mark -


#pragma mark NSIndexSet - Create


+ (OCATransformer *)indexSetFromArray {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSIndexSet class]
                           transform:^NSIndexSet *(NSArray *input) {
                               
                               NSMutableIndexSet *output = [[NSMutableIndexSet alloc] init];
                               for (NSNumber *number in input) {
                                   [output addIndex:number.unsignedIntegerValue];
                               }
                               return output;
                               
                           } reverse:^NSArray *(NSIndexSet *input) {
                               
                               NSMutableArray *output = [[NSMutableArray alloc] init];
                               [input enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                                   [output addObject:@(idx)];
                               }];
                               return output;
                           }]
            describe:@"index set from array"
            reverse:@"array from index set"];
}


+ (OCATransformer *)wrapIndex {
    return [[OCATransformer fromClass:[NSNumber class] toClass:[NSIndexSet class]
                            transform:^NSIndexSet *(NSNumber *input) {
                                
                                return [NSIndexSet indexSetWithIndex:input.unsignedIntegerValue];
                                
                            } reverse:^NSNumber *(NSIndexSet *input) {
                                NSUInteger lowest = input.firstIndex;
                                return (lowest == NSNotFound? nil : @(lowest));
                            }]
            describe:@"wrap index in set"
            reverse:@"lowest index"];
}


+ (OCATransformer *)wrapRange {
    return [[OCATransformer fromClass:[NSValue class] toClass:[NSIndexSet class]
                            transform:^NSIndexSet *(NSValue *input) {
                                
                                NSRange range = OCAUnbox(input, NSRange, NSMakeRange(0, 0));
                                return [NSIndexSet indexSetWithIndexesInRange:range];
                                
                            } reverse:^NSValue *(NSIndexSet *input) {
                                
                                __block NSRange range = NSMakeRange(NSNotFound, NSNotFound);
                                [input enumerateRangesUsingBlock:^(NSRange r, BOOL *stop) {
                                    range = r;
                                    *stop = YES;
                                }];
                                
                                return (range.location == NSNotFound? nil : OCABox(range));
                            }]
            describe:@"wrap range in set"
            reverse:@"lowest range"];
}





#pragma mark NSIndexSet -  Alter


+ (OCATransformer *)mutateIndexSet:(void(^)(NSMutableIndexSet *indexSet))block {
    return [[OCATransformer fromClass:[NSIndexSet class] toClass:[NSIndexSet class]
                            asymetric:^NSIndexSet *(NSIndexSet *input) {
                                
                                NSMutableIndexSet *mutable = [input mutableCopy];
                                block(mutable);
                                return mutable;
                            }]
            describe:@"mutate index set"];
}





#pragma mark NSIndexSet - Dispose


+ (OCATransformer *)lowestIndex {
    return [[OCATransformer fromClass:[NSIndexSet class] toClass:[NSNumber class]
                            asymetric:^NSNumber *(NSIndexSet *input) {
                                
                                NSUInteger lowest = input.firstIndex;
                                return (lowest == NSNotFound? nil : @(lowest));
                            }]
            describe:@"lowest index"];
}


+ (OCATransformer *)highestIndex {
    return [[OCATransformer fromClass:[NSIndexSet class] toClass:[NSNumber class]
                            asymetric:^NSNumber *(NSIndexSet *input) {
                                
                                NSUInteger highest = input.lastIndex;
                                return (highest == NSNotFound? nil : @(highest));
                            }]
            describe:@"highest index"];
}






#pragma mark -
#pragma mark Index Path
#pragma mark -


+ (OCATransformer *)indexPathFromArray {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSIndexPath class]
                            transform:^NSIndexPath *(NSArray *input) {
                                
                                NSIndexPath *indexPath = [[NSIndexPath alloc] init];
                                for (NSNumber *number in input) {
                                    indexPath = [indexPath indexPathByAddingIndex:number.unsignedIntegerValue];
                                }
                                return indexPath;
                                
                            } reverse:^NSArray *(NSIndexPath *input) {
                                
                                NSMutableArray *output = [[NSMutableArray alloc] init];
                                for (NSUInteger position = 0; position < input.length; position++) {
                                    NSUInteger index = [input indexAtPosition:position];
                                    [output addObject:@(index)];
                                }
                                return output;
                            }]
            describe:@"array from index path"];
}


+ (OCATransformer *)indexPathInSection:(NSUInteger)section {
    return [[OCATransformer fromClass:[NSNumber class] toClass:[NSIndexPath class]
                            asymetric:^NSIndexPath *(NSNumber *input) {
                                
                                const NSUInteger indexes[2] = { section, input.unsignedIntegerValue };
                                return [NSIndexPath indexPathWithIndexes:indexes length:2];
                                
                            }]
            describe:[NSString stringWithFormat:@"index path in section %@", @(section)]];
}





@end


