//
//  OCAFilter.h
//  Objective-Chain
//
//  Created by Martin Kiss on 16.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAMediator.h"





//! Filter is a Mediator, that evaluates predicates on the values. If the object evaluates to Yes, it is passed further, otherwise no action is made.
@interface OCAFilter : OCAMediator



#pragma mark Creating Filter

//! Designated initializer. Pass a predicate object you wish to evaluate on the values.
- (instancetype)initWithPredicate:(NSPredicate *)predicate;

//! Returns new Filer with given predicate.
+ (OCAFilter *)filterWithPredicate:(NSPredicate *)predicate;

//! Returns new Filter, that remembers number of consumed objects and passes all of them once it receives more than \c count.
+ (OCAFilter *)filterThatSkipsFirst:(NSUInteger)count;

//! Returns new Filter, that stores previously evaluated object and passes new objects only is they are not equal (as defined by isEqual: method).
+ (OCAFilter *)filterThatSkipsEqual;



#pragma mark Using Filter

//! Predicate as passed to the initializer.
@property (atomic, readonly, strong) NSPredicate *predicate;

//! This allows you to use Filter out of chain.
- (BOOL)validateObject:(id)object;



@end


