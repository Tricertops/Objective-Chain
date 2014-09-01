//
//  OCATransformer+Core.h
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer+Base.h"
#import "OCAKeyPathAccessor.h"
#import "OCAStructureAccessor.h"





@interface OCATransformer (Core)





#pragma mark Basic

+ (OCATransformer *)pass;
+ (OCATransformer *)discard;
+ (OCATransformer *)replaceWith:(id)replacement;



#pragma mark Conditions

+ (OCATransformer *)if:(NSPredicate *)predicate then:(NSValueTransformer *)thenTransformer else:(NSValueTransformer *)elseTransformer;
+ (OCATransformer *)passesPredicate:(NSPredicate *)predicate or:(id)replacement;
+ (OCATransformer *)replaceNil:(id)replacement;
+ (OCATransformer *)kindOfClass:(Class)theClass or:(id)replacement;
+ (OCATransformer *)ifYes:(id)yesReplacement ifNo:(id)noReplacement;



#pragma mark Boolean

+ (OCATransformer *)evaluatePredicate:(NSPredicate *)predicate;
+ (OCATransformer *)negateBoolean;



#pragma mark Accessors & Other

+ (OCATransformer *)access:(OCAAccessor *)accessor;
+ (OCATransformer *)modify:(OCAAccessor *)accessor value:(id)value;
+ (OCATransformer *)modify:(OCAAccessor *)accessor transformer:(NSValueTransformer *)transformer;
+ (OCATransformer *)evaluateExpression:(NSExpression *)expression;
+ (OCATransformer *)map:(NSDictionary *)dictionary;
+ (OCATransformer *)replace:(NSDictionary *)dictionary;
+ (OCATransformer *)makeCopy;



#pragma mark Control Flow

+ (OCATransformer *)sequence:(NSArray *)transformers;
+ (OCATransformer *)convertTo:(Class)finalClass using:(NSArray *)transformers;
+ (OCATransformer *)repeat:(NSUInteger)count transformer:(NSValueTransformer *)transformer;



#pragma mark Side Effects

+ (OCATransformer *)sideEffect:(void(^)(id value))block;
+ (OCATransformer *)debugPrintWithPrefix:(NSString *)prefix;





@end


