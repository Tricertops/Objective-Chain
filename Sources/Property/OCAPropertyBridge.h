//
//  OCAPropertyBridge.h
//  Objective-Chain
//
//  Created by Martin Kiss on 9.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAProducer.h"
#import "OCAConsumer.h"
#import "OCAKeyPathAccessor.h"





@interface OCAPropertyBridge : OCAProducer < OCAConsumer >



#pragma mark Creating Property Bridge

//TODO: Options: Prior, Changes, Weak Last, Duplicates

- (instancetype)initWithObject:(NSObject *)object keyPathAccessor:(OCAKeyPathAccessor *)accessor;


#pragma mark Attributes of Property Bridge

@property (atomic, readonly, weak) id object;
@property (atomic, readonly, copy) NSString *keyPath;
@property (atomic, readonly, copy) NSString *memberPath;
@property (atomic, readonly, strong) Class valueClass;


#pragma mark Consuming Values

- (Class)consumedValueClass;
- (void)consumeValue:(id)value;



@end





#define OCAProperty(OBJECT, KEYPATH, TYPE) \
(OCAPropertyBridge *)({ \
    id o = (OBJECT);\
    [[OCAPropertyBridge alloc] initWithObject:o keyPathAccessor:OCAKeyPath([o class], KEYPATH, TYPE)]; \
}) \


