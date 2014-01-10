//
//  OCAFoundation.m
//  Objective-Chain
//
//  Created by Martin Kiss on 5.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAFoundation.h"




#define CLAMP(MIN, VALUE, MAX) \
(typeof(VALUE))({ \
    typeof(VALUE) __min = (MIN); \
    typeof(VALUE) __value = (VALUE); \
    typeof(VALUE) __max = (MAX); \
    (__value > __max ? __max : (__value < __min ? __min : __value)); \
})










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





#pragma mark NSAttributedString


+ (OCATransformer *)stringWithAttributes:(NSDictionary *)attributes {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSAttributedString class] transform:^NSAttributedString *(NSString *input) {
        if ( ! input) return nil;
        return [[NSAttributedString alloc] initWithString:input attributes:attributes];
    } reverse:^NSString *(NSAttributedString *input) {
        return input.string;
    }]
            describe:[NSString stringWithFormat:@"attributed with %@", attributes]];
}


+ (OCATransformer *)addAttributes:(NSDictionary *)attributes {
    return [[OCATransformer fromClass:[NSAttributedString class] toClass:[NSAttributedString class] symetric:^NSAttributedString *(NSAttributedString *input) {
        NSMutableAttributedString *mutable = [input mutableCopy];
        [mutable addAttributes:attributes range:NSMakeRange(0, mutable.length)];
        return mutable;
    }]
            describe:[NSString stringWithFormat:@"add attributes %@", attributes]];
}


+ (OCATransformer *)addAttributes:(NSDictionary *)attributes range:(NSRange)range {
    return [[OCATransformer fromClass:[NSAttributedString class] toClass:[NSAttributedString class] symetric:^NSAttributedString *(NSAttributedString *input) {
        NSMutableAttributedString *mutable = [input mutableCopy];
        
        NSUInteger location = CLAMP(0, range.location, mutable.length);
        NSUInteger length = CLAMP(0, range.length, mutable.length - location);
        
        [mutable addAttributes:attributes range:NSMakeRange(location, length)];
        return mutable;
    }]
            describe:[NSString stringWithFormat:@"add attributes %@ at %@", attributes, NSStringFromRange(range)]];
}


+ (OCATransformer *)transformAttribute:(NSString *)attribute transformer:(NSValueTransformer *)transformer {
    return [[OCATransformer fromClass:[NSAttributedString class] toClass:[NSAttributedString class] transform:^NSAttributedString *(NSAttributedString *input) {
        NSMutableAttributedString *mutable = [input mutableCopy];
        [mutable enumerateAttribute:attribute
                            inRange:NSMakeRange(0, mutable.length)
                            options:kNilOptions
                         usingBlock:^(id value, NSRange range, BOOL *stop) {
                             id transformedValue = [transformer transformedValue:value];
                             [mutable addAttribute:attribute value:transformedValue range:range];
                         }];
        return mutable;
    } reverse:^NSAttributedString *(NSAttributedString *input) {
        NSMutableAttributedString *mutable = [input mutableCopy];
        [mutable enumerateAttribute:attribute
                            inRange:NSMakeRange(0, mutable.length)
                            options:kNilOptions
                         usingBlock:^(id value, NSRange range, BOOL *stop) {
                             id transformedValue = [transformer reverseTransformedValue:value];
                             [mutable addAttribute:attribute value:transformedValue range:range];
                         }];
        return mutable;
    }]
            describe:[NSString stringWithFormat:@"transform attribute %@ using %@", attribute, transformer]
            reverse:[NSString stringWithFormat:@"transform attribute %@ using %@", attribute, [transformer reversed]]];
}


+ (OCATransformer *)appendAttributedString:(NSAttributedString *)attributedString {
    return [[OCATransformer fromClass:[NSAttributedString class] toClass:[NSAttributedString class] transform:^NSAttributedString *(NSAttributedString *input) {
        NSMutableAttributedString *mutable = [input mutableCopy];
        [mutable appendAttributedString:attributedString];
        return mutable;
    } reverse:OCATransformationPass]
            describe:[NSString stringWithFormat:@"append %@", attributedString]
            reverse:@"pass"];
}


+ (OCATransformer *)attributedSubstringInRange:(NSRange)range {
    return [[OCATransformer fromClass:[NSAttributedString class] toClass:[NSAttributedString class] transform:^NSAttributedString *(NSAttributedString *input) {
        
        NSUInteger location = CLAMP(0, range.location, input.length);
        NSUInteger length = CLAMP(0, range.length, input.length - location);
        
        return [input attributedSubstringFromRange:NSMakeRange(location, length)];
    } reverse:OCATransformationPass]
            describe:[NSString stringWithFormat:@"substring %@", NSStringFromRange(range)]
            reverse:@"pass"];
}


+ (OCATransformer *)mutateAttributedString:(void(^)(NSMutableAttributedString *attributedString))block {
    return [[OCATransformer fromClass:[NSAttributedString class] toClass:[NSAttributedString class] asymetric:^NSAttributedString *(NSAttributedString *input) {
        NSMutableAttributedString *mutable = [input mutableCopy];
        block(mutable);
        return mutable;
    }]
            describe:[NSString stringWithFormat:@"mutate attributed string"]];
}





#pragma mark NSData


+ (OCATransformer *)dataFromFile {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSData class] asymetric:^NSData *(NSString *input) {
        if ( ! input) return nil;
        return [NSData dataWithContentsOfFile:input];
    }]
            describe:@"data from file"];
}


+ (OCATransformer *)dataFromString {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSData class] transform:^NSData *(NSString *input) {
        return [input dataUsingEncoding:NSUTF8StringEncoding];
    } reverse:^NSString *(NSData *input) {
        if ( ! input) return nil;
        return [[NSString alloc] initWithData:input encoding:NSUTF8StringEncoding];
    }]
            describe:@"data from string"
            reverse:@"string from data"];
}


+ (OCATransformer *)archiveBinary:(BOOL)binary {
    return [[OCATransformer fromClass:nil toClass:[NSData class] transform:^NSData *(id input) {
        if ( ! input) return nil;
        NSMutableData *output = [[NSMutableData alloc] init];
        
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:output];
        archiver.outputFormat = (binary? NSPropertyListBinaryFormat_v1_0 : NSPropertyListXMLFormat_v1_0);
        [archiver encodeRootObject:input];
        [archiver finishEncoding];
        
        return output;
    } reverse:^id(NSData *input) {
        if ( ! input) return nil;
        return [NSKeyedUnarchiver unarchiveObjectWithData:input];
    }]
            describe:[NSString stringWithFormat:@"archive to %@", (binary? @"binary" : @"XML")]
            reverse:@"unarchive"];
}


+ (OCATransformer *)serializePropertyListBinary:(BOOL)binary {
    return [[OCATransformer fromClass:nil toClass:[NSData class] transform:^NSData *(id input) {
        if ( ! input) return nil;
        
        NSPropertyListFormat format = (binary? NSPropertyListBinaryFormat_v1_0 : NSPropertyListXMLFormat_v1_0);
        BOOL isValid = [NSPropertyListSerialization propertyList:input isValidForFormat:format];
        if ( ! isValid) return nil;
        
        return [NSPropertyListSerialization dataWithPropertyList:input format:format options:kNilOptions error:nil];
    } reverse:^id(NSData *input) {
        if ( ! input) return nil;
        return [NSPropertyListSerialization propertyListWithData:input options:kNilOptions format:nil error:nil];
    }]
            describe:[NSString stringWithFormat:@"serialize to %@ property list", (binary? @"binary" : @"XML")]
            reverse:@"deserialize property list"];
}


+ (OCATransformer *)serializeJSONPretty:(BOOL)pretty {
    return [[OCATransformer fromClass:nil toClass:[NSData class] transform:^NSData *(id input) {
        if ( ! input) return nil;
        
        BOOL isValid = [NSJSONSerialization isValidJSONObject:input];
        if ( ! isValid) return nil;
        
        return [NSJSONSerialization dataWithJSONObject:input options:(pretty? NSJSONWritingPrettyPrinted : kNilOptions) error:nil];
    } reverse:^id(NSData *input) {
        if ( ! input) return nil;
        return [NSJSONSerialization JSONObjectWithData:input options:kNilOptions error:nil];
    }]
            describe:[NSString stringWithFormat:@"serialize to %@JSON", (pretty? @"pretty " : @"")]
            reverse:@"deserialize JSON"];
}


+ (OCATransformer *)decodeBase64Data {
    return [[OCATransformer fromClass:[NSData class] toClass:[NSData class] transform:^NSData *(NSData *input) {
        if ( ! input) return nil;
        return [[NSData alloc] initWithBase64EncodedData:input options:kNilOptions];
    } reverse:^NSData *(NSData *input) {
        if ( ! input) return nil;
        return [input base64EncodedDataWithOptions:kNilOptions];
    }]
            describe:@"decode base64"
            reverse:@"encode base64"];
}


+ (OCATransformer *)encodeBase64Data {
    return [[OCAFoundation decodeBase64Data] reversed];
}


+ (OCATransformer *)subdataWithRange:(NSRange)range {
    return [[OCATransformer fromClass:[NSData class] toClass:[NSData class] transform:^NSData *(NSData *input) {
        
        NSUInteger location = CLAMP(0, range.location, input.length);
        NSUInteger length = CLAMP(0, range.length, input.length - location);
        
        return [input subdataWithRange:NSMakeRange(location, length)];
    } reverse:OCATransformationPass]
            describe:[NSString stringWithFormat:@"subdata at %@", NSStringFromRange(range)]
            reverse:@"pass"];
}


+ (OCATransformer *)unarchive {
    return [[OCAFoundation archiveBinary:YES] reversed];
}


+ (OCATransformer *)deserializePropertyListMutable:(BOOL)mutable {
    return [[OCATransformer fromClass:[NSData class] toClass:nil transform:^id(NSData *input) {
        if ( ! input) return nil;
        return [NSPropertyListSerialization propertyListWithData:input options:(mutable? NSPropertyListMutableContainers : kNilOptions) format:nil error:nil];
    } reverse:^NSData *(id input) {
        if ( ! input) return nil;
        
        BOOL isValid = [NSPropertyListSerialization propertyList:input isValidForFormat:NSPropertyListXMLFormat_v1_0];
        if ( ! isValid) return nil;
        
        return [NSPropertyListSerialization dataWithPropertyList:input format:NSPropertyListXMLFormat_v1_0 options:kNilOptions error:nil];
    }]
            describe:[NSString stringWithFormat:@"deserialize %@property list", (mutable? @"mutable " : @"")]
            reverse:@"serialize property list"];
}


+ (OCATransformer *)deserializeJSONMutable:(BOOL)mutable {
    return [[OCATransformer fromClass:[NSData class] toClass:nil transform:^id(NSData *input) {
        if ( ! input) return nil;
        return [NSJSONSerialization JSONObjectWithData:input options:(mutable? NSJSONReadingMutableContainers : kNilOptions) error:nil];
    } reverse:^NSData *(id input) {
        if ( ! input) return nil;
        
        BOOL isValid = [NSJSONSerialization isValidJSONObject:input];
        if ( ! isValid) return nil;
        
        return [NSJSONSerialization dataWithJSONObject:input options:kNilOptions error:nil];
    }]
            describe:[NSString stringWithFormat:@"deserialize %@JSON", (mutable? @"mutable " : @"")]
            reverse:@"serialize JSON"];
}





@end


