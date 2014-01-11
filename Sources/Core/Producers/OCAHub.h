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
} OCAHubType;





@interface OCAHub : OCAProducer



#pragma mark Creating Hub

- (instancetype)initWithType:(OCAHubType)type producers:(NSArray *)producers;
+ (instancetype)merge:(NSArray *)producers;
+ (instancetype)combine:(NSArray *)producers;


#pragma mark Attributes of Hub

@property (atomic, readonly, assign) OCAHubType type;
@property (atomic, readonly, copy) NSArray *producers;



@end





@interface OCAProducer (OCAHub)


- (OCAHub *)mergeWith:(OCAProducer *)producer;
- (OCAHub *)combineWith:(OCAProducer *)producer;


@end


