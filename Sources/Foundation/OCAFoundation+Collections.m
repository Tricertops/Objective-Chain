//
//  OCAFoundation+Collections.m
//  Objective-Chain
//
//  Created by Martin Kiss on 10.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAFoundation+Collections.h"
#import "NSArray+Ordinals.h"





@implementation OCAFoundation (Collections)





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
    return [[OCAFoundation mutateArray:^(NSMutableArray *array) {
        for (NSUInteger sourceIndex = 1; sourceIndex < array.count; sourceIndex++) {
            
            NSUInteger destinationRange = array.count - sourceIndex;
            NSUInteger destinationIndex = arc4random_uniform((u_int32_t)destinationRange + 1);
            
            [array exchangeObjectAtIndex:sourceIndex withObjectAtIndex:destinationIndex];
        }
    }]
            describe:@"randomize order"];
}


+ (OCATransformer *)removeNullsFromArray {
    return [[OCAFoundation mutateArray:^(NSMutableArray *array) {
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
                                
                                return [input valueAtIndex:index];
                            }]
            describe:[NSString stringWithFormat:@"index %@", @(index)]];
}


+ (OCATransformer *)joinWithString:(NSString *)string {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSString class]
                            asymetric:^NSString *(NSArray *input) {
                                
                                return [input componentsJoinedByString:string];
                            }]
            describe:[NSString stringWithFormat:@"join “%@”", string]];
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





@end


