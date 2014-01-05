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
            [output addObject:transformed ?: [NSNull null]];
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


+ (OCATransformer *)objectsAtIndexes:(NSIndexSet *)indexes {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSArray class] transform:^NSArray *(NSArray *input) {
        if ( ! input) return nil;
        
        NSIndexSet *safeIndexes = [indexes indexesPassingTest:^BOOL(NSUInteger index, BOOL *stop) {
            return (index < [input count]);
        }];
        return [input objectsAtIndexes:safeIndexes];
        
    } reverse:OCATransformationPass]
            describe:[NSString stringWithFormat:@"objects at indexes %@", indexes]
            reverse:@"pass"];
}



+ (OCATransformer *)subarrayToIndex:(NSInteger)index {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSArray class] transform:^NSArray *(NSArray *input) {
        if ( ! input) return nil;
        
        NSInteger length = (index < 0? input.count + index : index);
        length = CLAMP(0, length, input.count);
        return [input subarrayWithRange:NSMakeRange(0, length)];
        
    } reverse:OCATransformationPass]
            describe:[NSString stringWithFormat:@"subarray to index %@", @(index)]
            reverse:@"pass"];
}


+ (OCATransformer *)subarrayFromIndex:(NSInteger)index {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSArray class] transform:^NSArray *(NSArray *input) {
        if ( ! input) return nil;
        
        NSInteger location = (index < 0? input.count + index : index);
        location = CLAMP(0, location, input.count);
        return [input subarrayWithRange:NSMakeRange(location, input.count - location)];
        
    } reverse:OCATransformationPass]
            describe:[NSString stringWithFormat:@"subarray from index %@", @(index)]
            reverse:@"pass"];
}


+ (OCATransformer *)subarrayWithRange:(NSRange)range {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSArray class] transform:^NSArray *(NSArray *input) {
        if ( ! input) return nil;
        
        NSUInteger location = CLAMP(0, range.location, input.count);
        NSUInteger length = CLAMP(0, range.length, input.count - location);
        return [input subarrayWithRange:NSMakeRange(location, length)];
        
    } reverse:OCATransformationPass]
            describe:[NSString stringWithFormat:@"subarray with range %@", NSStringFromRange(range)]
            reverse:@"pass"];
}


+ (OCATransformer *)transformArray:(NSValueTransformer *)transformer {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSArray class] transform:^NSArray *(NSArray *input) {
        if ( ! input) return nil;
        NSMutableArray *output = [[NSMutableArray alloc] init];
        
        for (id object in input) {
            id transformed = [transformer transformedValue:object];
            [output addObject:transformed ?: [NSNull null]];
        }
        return output;
        
    } reverse:^NSArray *(NSArray *input) {
        if ( ! input) return nil;
        NSMutableArray *output = [[NSMutableArray alloc] init];
        
        for (id object in input) {
            id transformed = [transformer reverseTransformedValue:object];
            [output addObject:transformed ?: [NSNull null]];
        }
        return output;
    }]
            describe:[NSString stringWithFormat:@"for each %@", transformer]
            reverse:[NSString stringWithFormat:@"for each %@", [transformer reversed]]];
}


+ (OCATransformer *)filterArray:(NSPredicate *)predicate {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSArray class] symetric:^NSArray *(NSArray *input) {
        return [input filteredArrayUsingPredicate:predicate];
    }]
            describe:[NSString stringWithFormat:@"filter (%@)", predicate]];
}


+ (OCATransformer *)sortArray:(NSArray *)sortDescriptors {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSArray class] symetric:^NSArray *(NSArray *input) {
        return [input sortedArrayUsingDescriptors:sortDescriptors];
    }]
            describe:[NSString stringWithFormat:@"sort by (%@)", [sortDescriptors componentsJoinedByString:@", "]]];
}


+ (OCATransformer *)flattenArrayRecursively:(BOOL)recursively {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSArray class] asymetric:^id(id input) {
        if ( ! input) return nil;
        NSMutableArray *output = [[NSMutableArray alloc] init];
        NSMutableArray *stack = [NSMutableArray arrayWithArray:input];
        
        while (stack.count) {
            id object = [stack objectAtIndex:0];
            [stack removeObjectAtIndex:0];
            
            BOOL isSubarray = [object isKindOfClass:[NSArray class]];
            if (isSubarray) {
                NSArray *subarray = (NSArray *)object;
                if (recursively) {
                    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, subarray.count)];
                    [stack insertObjects:subarray atIndexes:indexes];
                }
                else {
                    [output addObjectsFromArray:subarray];
                }
            }
            else {
                [output addObject:object];
            }
        }
        
        return output;
    }]
            describe:(recursively? @"flatten recursively" : @"flatten")];
}


+ (OCATransformer *)randomizeArray {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSArray class] symetric:^NSArray *(NSArray *input) {
        NSMutableArray *output = [NSMutableArray arrayWithArray:input];
        
        for (NSUInteger sourceIndex = 1; sourceIndex < input.count; sourceIndex++) {
            NSUInteger destinationRange = input.count - sourceIndex;
            NSUInteger destinationIndex = arc4random_uniform((u_int32_t)destinationRange + 1);
            [output exchangeObjectAtIndex:sourceIndex withObjectAtIndex:destinationIndex];
        }
        return output;
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
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSArray class] asymetric:^NSArray *(NSArray *input) {
        NSMutableArray *output = [NSMutableArray arrayWithArray:input];
        block(output);
        return output;
    }]
            describe:@"mutate array"];
}


+ (OCATransformer *)objectAtIndex:(NSInteger)index {
    return [[OCATransformer fromClass:[NSArray class] toClass:nil asymetric:^id(NSArray *input) {
        
        NSInteger realIndex = (index < 0? input.count + index : index);
        if (realIndex < 0 || realIndex >= input.count) return nil;
        
        return [input objectAtIndex:realIndex];
    }]
            describe:[NSString stringWithFormat:@"index %@", @(index)]];
}


+ (OCATransformer *)joinWithString:(NSString *)string {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSString class] asymetric:^NSString *(NSArray *input) {
        return [input componentsJoinedByString:string];
    }]
            describe:[NSString stringWithFormat:@"join “%@”", string]];
}


+ (OCATransformer *)joinWithString:(NSString *)string last:(NSString *)lastString {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSString class] asymetric:^NSString *(NSArray *input) {
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




