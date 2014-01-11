//
//  OCAPredicate.h
//  Objective-Chain
//
//  Created by Martin Kiss on 11.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAObject.h"
#import "OCAAccessor.h"





@interface NSPredicate (OCAPredicateCompatibility)


- (instancetype)negate;


@end





@interface OCAPredicate : OCAObject


+ (NSPredicate *)isNil;
+ (NSPredicate *)predicateForClass:(Class)class block:(BOOL(^)(id object))block;


@end





@interface OCAPredicate (Predefined)



+ (NSPredicate *)isEmpty;
+ (NSPredicate *)pass;
+ (NSPredicate *)discard;
+ (NSPredicate *)isKindOf:(Class)class;

+ (NSPredicate *)not:(NSPredicate *)predicate;
+ (NSPredicate *)and:(NSArray *)subpredicates;
+ (NSPredicate *)or:(NSArray *)subpredicates;
+ (NSPredicate *)all:(NSPredicate *)predicate;
+ (NSPredicate *)any:(NSPredicate *)predicate;

+ (NSPredicate *)predicateForClass:(Class)class predicate:(NSPredicate *)predicate;
+ (NSPredicate *)predicateFor:(Class)class format:(NSString *)format, ...;
+ (NSPredicate *)access:(OCAAccessor *)booleanAccessor;
+ (NSPredicate *)compare:(OCAAccessor *)accessor operator:(NSString *)operator value:(id)value;
+ (NSPredicate *)compare:(OCAAccessor *)accessor using:(BOOL(^)(id input))block;



@end


