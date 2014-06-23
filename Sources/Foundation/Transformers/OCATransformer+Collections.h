//
//  OCATransformer+Collections.h
//  Objective-Chain
//
//  Created by Martin Kiss on 10.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer+Base.h"





@interface OCATransformer (Collections)



+ (OCATransformer *)countCollection;
+ (OCATransformer *)objectForKey:(id)key;




#pragma mark -
#pragma mark Array
#pragma mark -


#pragma mark Creating Array

+ (OCATransformer *)branchArray:(NSArray *)transformers;
+ (OCATransformer *)wrapInArray;
+ (OCATransformer *)arrayFromFile;


#pragma mark Getting Subarray

+ (OCATransformer *)objectsAtIndexes:(NSIndexSet *)indexes;
+ (OCATransformer *)subarrayToIndex:(NSInteger)index;
+ (OCATransformer *)subarrayFromIndex:(NSInteger)index;
+ (OCATransformer *)subarrayWithRange:(NSRange)range;


#pragma mark Altering Array

+ (OCATransformer *)transformArray:(NSValueTransformer *)transformer;
+ (OCATransformer *)filterArray:(NSPredicate *)predicate;
+ (OCATransformer *)sortArray:(NSArray *)sortDescriptors;
+ (OCATransformer *)flattenArrayRecursively:(BOOL)recursively;
+ (OCATransformer *)randomizeArray;
+ (OCATransformer *)removeNullsFromArray;
+ (OCATransformer *)mutateArray:(void(^)(NSMutableArray *array))block;


#pragma mark Disposing Array

+ (OCATransformer *)objectAtIndex:(NSInteger)index;
+ (OCATransformer *)joinWithString:(NSString *)string;
+ (OCATransformer *)joinWithAttributedString:(NSAttributedString *)attrString;
+ (OCATransformer *)joinWithString:(NSString *)string last:(NSString *)lastString;

+ (OCATransformer *)objectFromArray:(NSArray *)objects;
+ (OCATransformer *)indexInArray:(NSArray *)objects;



#pragma mark -
#pragma mark Dictionary
#pragma mark -


#pragma mark Creating Dictionary

+ (OCATransformer *)dictionaryFromFile;
+ (OCATransformer *)mappedArray:(NSValueTransformer *)transformer;
+ (OCATransformer *)keyedArray:(NSArray *)keys;
+ (OCATransformer *)mergeDictionaries;


#pragma mark Altering Dictionary

+ (OCATransformer *)filteredDictionary:(NSPredicate *)predicate;
+ (OCATransformer *)transformValues:(NSValueTransformer *)transformer;
+ (OCATransformer *)mutateDictionary:(void(^)(NSMutableDictionary *dictionary))block;


#pragma mark Disposing Dictionary

+ (OCATransformer *)joinPairs:(NSString *)string;
+ (OCATransformer *)keysForValue:(id)value;



#pragma mark -
#pragma mark Index Set
#pragma mark -


#pragma mark Creating Index Set

+ (OCATransformer *)indexSetFromArray;
+ (OCATransformer *)wrapIndex;
+ (OCATransformer *)wrapRange;


#pragma mark Altering Index Set

+ (OCATransformer *)mutateIndexSet:(void(^)(NSMutableIndexSet *indexSet))block;


#pragma mark Disposing Index Set

+ (OCATransformer *)lowestIndex;
+ (OCATransformer *)highestIndex;



#pragma mark -
#pragma mark Index Path
#pragma mark -


+ (OCATransformer *)indexPathFromArray;
+ (OCATransformer *)indexPathInSection:(NSUInteger)section;



@end


