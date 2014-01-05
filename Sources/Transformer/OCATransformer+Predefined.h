//
//  OCATransformer+Predefined.h
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer.h"
#import "OCAStructureAccessor.h"





@interface OCATransformer (Predefined)



#pragma mark Basic

+ (OCATransformer *)pass;
+ (OCATransformer *)null;
+ (OCATransformer *)nonNull:(id)replacement;
+ (OCATransformer *)copy;
//TODO: count
//TODO: length
+ (OCATransformer *)replaceWith:(id)replacement;
+ (OCATransformer *)map:(NSDictionary *)dictionary;
+ (OCATransformer *)ofClass:(Class)class or:(id)replacement;


#pragma mark Control Flow

+ (OCATransformer *)sequence:(NSArray *)transformers;
+ (OCATransformer *)convertTo:(Class)finalClass using:(NSArray *)transformers;
+ (OCATransformer *)repeat:(NSUInteger)count transformer:(NSValueTransformer *)transformer;
+ (OCATransformer *)if:(NSPredicate *)predicate then:(NSValueTransformer *)thenTransformer else:(NSValueTransformer *)elseTransformer;


#pragma mark Access Members

+ (OCATransformer *)traverseKeyPath:(NSString *)keypath;
//TODO: valueOfProperty:
//TODO: setValue:ofProperty:
//TODO: valueForKeyPath:
//TODO: setValue:forKeyPath:
+ (OCATransformer *)accessStruct:(OCAStructureAccessor *)structAccessor;
+ (OCATransformer *)modifyStruct:(OCAStructureAccessor *)structAccessor value:(NSValue *)value;


#pragma mark Array
//TODO: Move to Foundation

+ (OCATransformer *)count;
+ (OCATransformer *)branch:(NSArray *)transformers;
+ (OCATransformer *)pickIndexes:(NSIndexSet *)indexes;
+ (OCATransformer *)enumerate:(NSValueTransformer *)transformer;
+ (OCATransformer *)filter:(NSPredicate *)predicate; //TODO: replacement
+ (OCATransformer *)removeNulls;
+ (OCATransformer *)sort:(NSArray *)descriptors;


#pragma mark Other

+ (OCATransformer *)mutableCopy; //TODO: Useless
+ (OCATransformer *)mapFromTable:(NSMapTable *)mapTable; //TODO: Useless


#pragma mark Side Effects

+ (OCATransformer *)sideEffect:(void(^)(id value))block;
+ (OCATransformer *)debugPrintWithMarker:(NSString *)marker;



@end
