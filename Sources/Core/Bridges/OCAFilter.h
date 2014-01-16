//
//  OCAFilter.h
//  Objective-Chain
//
//  Created by Martin Kiss on 16.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCABridge.h"





@interface OCAFilter : OCABridge



#pragma mark Creating Filter

- (instancetype)initWithValueClass:(Class)valueClass predicate:(NSPredicate *)predicate;

+ (OCAFilter *)evaluate:(NSPredicate *)predicate;


#pragma mark Using Filter

@property (atomic, readonly, strong) NSPredicate *predicate;

- (BOOL)validateObject:(id)object;


#pragma mark Filter as a Consumer

- (void)consumeValue:(id)value;
- (void)finishConsumingWithError:(NSError *)error;



@end





@interface OCAProducer (OCAFilter)


- (OCABridge *)filter:(NSPredicate *)predicate;


@end


