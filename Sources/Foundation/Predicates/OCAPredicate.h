//
//  OCAPredicate.h
//  Objective-Chain
//
//  Created by Martin Kiss on 11.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAObject.h"
#import "OCAAccessor.h"
#import "OCAProperty.h"





@interface NSPredicate (OCAPredicateCompatibility)


- (instancetype)negate;


@end





@interface OCAPredicate : OCAObject


+ (NSPredicate *)isNil;
+ (NSPredicate *)isNotNil;
+ (NSPredicate *)predicateForClass:(Class)theClass block:(BOOL(^)(id object))block;


@end





@interface OCAPredicate (Predefined)



+ (NSPredicate *)isTrue;
+ (NSPredicate *)isFalse;
+ (NSPredicate *)isEmpty;
+ (NSPredicate *)isNotEmpty;

+ (NSPredicate *)pass;
+ (NSPredicate *)discard;

+ (NSPredicate *)isKindOf:(Class)theClass;

+ (NSPredicate *)not:(NSPredicate *)predicate;
+ (NSPredicate *)and:(NSArray *)subpredicates;
+ (NSPredicate *)or:(NSArray *)subpredicates;
+ (NSPredicate *)all:(NSPredicate *)predicate;
+ (NSPredicate *)any:(NSPredicate *)predicate;

+ (NSPredicate *)predicateForClass:(Class)theClass predicate:(NSPredicate *)predicate;
+ (NSPredicate *)predicateFor:(Class)theClass format:(NSString *)format, ...;

+ (NSPredicate *)isProperty:(OCAProperty *)property;
+ (NSPredicate *)compareProperty:(OCAProperty *)property using:(NSPredicate *)predicate;

+ (NSPredicate *)compare:(OCAAccessor *)accessor using:(NSPredicate *)predicate;
+ (NSPredicate *)compare:(OCAAccessor *)accessor format:(NSString *)operatorFormat value:(id)value;

+ (NSPredicate *)operator:(NSPredicateOperatorType)theOperator options:(NSComparisonPredicateOptions)options value:(id)value;
+ (NSPredicate *)isLessThan:(id)value;
+ (NSPredicate *)isLessThanOrEqual:(id)value;
+ (NSPredicate *)isGreaterThan:(id)value;
+ (NSPredicate *)isGreaterThanOrEqual:(id)value;
+ (NSPredicate *)isEqualTo:(id)value;
+ (NSPredicate *)isNotEqualTo:(id)value;
+ (NSPredicate *)matches:(NSString *)regex;
+ (NSPredicate *)isLike:(NSString *)string;
+ (NSPredicate *)beginsWith:(id)value;
+ (NSPredicate *)endsWith:(id)value;
+ (NSPredicate *)isIn:(id)value;
+ (NSPredicate *)contains:(id)value;
+ (NSPredicate *)isBetween:(id)lower and:(id)upper;



@end


