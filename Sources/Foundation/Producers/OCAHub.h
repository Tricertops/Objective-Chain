//
//  OCAHub.h
//  Objective-Chain
//
//  Created by Martin Kiss on 5.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAProducer.h"



typedef enum : NSInteger {
    OCAHubTypeMerge,
    OCAHubTypeCombine,
    OCAHubTypeDependency,
} OCAHubType;





@interface OCAHub : OCAProducer



#pragma mark Creating Hub

- (instancetype)initWithType:(OCAHubType)type producers:(NSArray *)producers;
+ (instancetype)merge:(OCAProducer *)producers, ... NS_REQUIRES_NIL_TERMINATION;
+ (instancetype)combine:(OCAProducer *)producers, ... NS_REQUIRES_NIL_TERMINATION;
+ (OCAProducer *)allTrue:(OCAProducer *)producers, ... NS_REQUIRES_NIL_TERMINATION;
+ (OCAProducer *)anyTrue:(OCAProducer *)producers, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark Attributes of Hub

@property (atomic, readonly, assign) OCAHubType type;
@property (atomic, readonly, copy) NSArray *producers; //TODO: Make mutable



@end


