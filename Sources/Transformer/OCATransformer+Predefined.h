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
+ (OCATransformer *)mutableCopy;
+ (OCATransformer *)replaceWith:(id)replacement;


#pragma mark Control Flow

+ (OCATransformer *)sequence:(NSArray *)transformers;
+ (OCATransformer *)convertTo:(Class)finalClass using:(NSArray *)transformers;
+ (OCATransformer *)repeat:(NSUInteger)count transformer:(NSValueTransformer *)transformer;
+ (OCATransformer *)if:(NSPredicate *)predicate then:(NSValueTransformer *)thenTransformer else:(NSValueTransformer *)elseTransformer;


#pragma mark Access Members

+ (OCATransformer *)traverseKeyPath:(NSString *)keypath;
+ (OCATransformer *)accessStruct:(OCAStructureAccessor *)structAccessor;
+ (OCATransformer *)modifyStruct:(OCAStructureAccessor *)structAccessor value:(NSValue *)value;


#pragma mark Other

+ (OCATransformer *)map:(NSDictionary *)dictionary;
+ (OCATransformer *)mapFromTable:(NSMapTable *)mapTable;
+ (OCATransformer *)ofClass:(Class)class or:(id)replacement;


#pragma mark Side Effects

+ (OCATransformer *)sideEffect:(void(^)(id value))block;
+ (OCATransformer *)debugPrintWithMarker:(NSString *)marker;



@end
