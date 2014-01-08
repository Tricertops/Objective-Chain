//
//  OCATransformer+Predefined.h
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer.h"
#import "OCAAccessor.h"





@interface OCATransformer (Predefined)





#pragma mark Basic

+ (OCATransformer *)pass;

+ (OCATransformer *)null;
+ (OCATransformer *)replaceWith:(id)replacement;
+ (OCATransformer *)ifNull:(id)replacement;
+ (OCATransformer *)kindOfClass:(Class)class or:(id)replacement;
+ (OCATransformer *)passes:(NSPredicate *)predicate or:(id)replacement;
+ (OCATransformer *)test:(NSPredicate *)predicate;
+ (OCATransformer *)not;

+ (OCATransformer *)count;
+ (OCATransformer *)map:(NSDictionary *)dictionary;


#pragma mark Control Flow

+ (OCATransformer *)sequence:(NSArray *)transformers;
+ (OCATransformer *)convertTo:(Class)finalClass using:(NSArray *)transformers;
+ (OCATransformer *)repeat:(NSUInteger)count transformer:(NSValueTransformer *)transformer;
+ (OCATransformer *)if:(NSPredicate *)predicate then:(NSValueTransformer *)thenTransformer else:(NSValueTransformer *)elseTransformer;


#pragma mark Key-Value Coding

+ (OCATransformer *)accessKeyPath:(NSString *)keypath;
+ (OCATransformer *)modifyKeyPath:(NSString *)keypath value:(id)value;
+ (OCATransformer *)transformKeyPath:(NSString *)keypath transformer:(NSValueTransformer *)transformer;


#pragma mark Accessors

+ (OCATransformer *)access:(OCAAccessor *)accessor;
+ (OCATransformer *)modify:(OCAAccessor *)accessor value:(id)value;


#pragma mark Side Effects

+ (OCATransformer *)sideEffect:(void(^)(id value))block;
+ (OCATransformer *)debugPrintWithMarker:(NSString *)marker;





@end


