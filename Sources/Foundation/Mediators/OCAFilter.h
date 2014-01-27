//
//  OCAFilter.h
//  Objective-Chain
//
//  Created by Martin Kiss on 16.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAMediator.h"





@interface OCAFilter : OCAMediator



#pragma mark Creating Filter

- (instancetype)initWithPredicate:(NSPredicate *)predicate;

+ (OCAFilter *)predicate:(NSPredicate *)predicate;


#pragma mark Using Filter

@property (atomic, readonly, strong) NSPredicate *predicate;

- (BOOL)validateObject:(id)object;


#pragma mark Filter as a Consumer

- (void)consumeValue:(id)value;
- (void)finishConsumingWithError:(NSError *)error;



@end





@interface OCAProducer (OCAFilter)


- (OCAFilter *)produceFiltered:(NSPredicate *)predicate CONVENIENCE;
//TODO: Methods for specific instances.


@end


