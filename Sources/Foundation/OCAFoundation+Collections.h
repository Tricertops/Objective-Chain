//
//  OCAFoundation+Collections.h
//  Objective-Chain
//
//  Created by Martin Kiss on 10.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAFoundation+Base.h"





@interface OCAFoundation (Collections)



#pragma mark NSArray

/// Materialize Array
+ (OCATransformer *)branchArray:(NSArray *)transformers;
+ (OCATransformer *)wrapInArray;
+ (OCATransformer *)arrayFromFile;

/// Altering Array
+ (OCATransformer *)objectsAtIndexes:(NSIndexSet *)indexes;
+ (OCATransformer *)subarrayToIndex:(NSInteger)index;
+ (OCATransformer *)subarrayFromIndex:(NSInteger)index;
+ (OCATransformer *)subarrayWithRange:(NSRange)range;
+ (OCATransformer *)transformArray:(NSValueTransformer *)transformer;
+ (OCATransformer *)filterArray:(NSPredicate *)predicate;
+ (OCATransformer *)sortArray:(NSArray *)sortDescriptors;
+ (OCATransformer *)flattenArrayRecursively:(BOOL)recursively;
+ (OCATransformer *)randomizeArray;
+ (OCATransformer *)removeNullsFromArray;
+ (OCATransformer *)mutateArray:(void(^)(NSMutableArray *array))block;

/// Dematerialize Array
+ (OCATransformer *)objectAtIndex:(NSInteger)index;
+ (OCATransformer *)joinWithString:(NSString *)string;
+ (OCATransformer *)joinWithString:(NSString *)string last:(NSString *)lastString;


#pragma mark NSDictionary

/// Constructors
//TODO: dictionaryFromFile
//TODO: mappedArray: (transformer)
//TODO: namedArray: (array of names)
//TODO: dictionaryFromProperties:

/// Transformators
//TODO: filteredDictionary:
//TODO: mutateDictionary: (block)

/// Destructors
//TODO: joinPairsWithString:
//TODO: keysForValue:
//TODO: transformValues:
//TODO: sortedKeysByValues:


#pragma mark NSIndexSet

/// Constructors
//TODO: indexSetFromArray
//TODO: wrapIndex
//TODO: wrapRange

/// Destructors
//TODO: lowestIndex
//TODO: highestIndex


#pragma mark NSIndexPath

/// Constructors
//TODO: indexPathFromArray
//TODO: indexPathWithSection:



@end


