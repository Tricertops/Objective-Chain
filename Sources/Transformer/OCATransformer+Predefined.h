//
//  OCATransformer+Predefined.h
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer.h"





@interface OCATransformer (Predefined)



+ (OCATransformer *)pass;
+ (OCATransformer *)null;

+ (OCATransformer *)sequence:(NSArray *)transformers;
+ (OCATransformer *)convertTo:(Class)finalClass using:(NSArray *)transformers;
+ (OCATransformer *)repeat:(NSUInteger)count transformer:(NSValueTransformer *)transformer;

+ (OCATransformer *)copy;
+ (OCATransformer *)mutableCopy;

+ (OCATransformer *)if:(NSPredicate *)predicate then:(NSValueTransformer *)thenTransformer else:(NSValueTransformer *)elseTransformer;
+ (OCATransformer *)traverseKeyPath:(NSString *)keypath;
//TODO: +property:(OCAProperty *)property, that knows input and output classes
//TODO: +accessStructure:
//TODO: +setStructureMember: value:
+ (OCATransformer *)replaceWith:(id)replacement;
+ (OCATransformer *)map:(NSDictionary *)dictionary;
+ (OCATransformer *)mapFromTable:(NSMapTable *)mapTable;
+ (OCATransformer *)ofClass:(Class)class or:(id)replacement;

+ (OCATransformer *)debugPrintWithMarker:(NSString *)marker;



@end
