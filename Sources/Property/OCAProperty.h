//
//  OCAProperty.h
//  Objective-Chain
//
//  Created by Martin Kiss on 9.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAProducer.h"
#import "OCAConsumer.h"
#import "OCAKeyPathAccessor.h"





@interface OCAProperty : OCAProducer < OCAConsumer >



#pragma mark Creating Property

//TODO: Options: Prior, Changes, Weak Last

- (instancetype)initWithObject:(NSObject *)object keyPathAccessor:(OCAKeyPathAccessor *)accessor;


#pragma mark Attributes of Property

@property (atomic, readonly, weak) id object;
@property (atomic, readonly, copy) NSString *keyPath;
@property (atomic, readonly, copy) NSString *memberPath;
@property (atomic, readonly, strong) Class valueClass;


#pragma mark Consuming Values

- (Class)consumedValueClass;
- (void)consumeValue:(id)value;



@end


