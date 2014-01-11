//
//  OCABridge.h
//  Objective-Chain
//
//  Created by Martin Kiss on 5.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAProducer.h"
#import "OCAConsumer.h"





/// Bridge is a Producer and Consumer, that forwards consumed values.
@interface OCABridge : OCAProducer < OCAConsumer >



#pragma mark Creating Bridge

- (instancetype)initWithValueClass:(Class)valueClass;

+ (instancetype)bridge;
+ (instancetype)bridgeForClass:(Class)class;



@end





@interface OCAProducer (OCABridge)


- (OCAProducer *)bridgeOn:(OCAQueue *)queue;
- (OCAProducer *)bridgeWithFilter:(NSPredicate *)filter transform:(NSValueTransformer *)transformer;
- (OCAProducer *)bridgeOn:(OCAQueue *)queue filter:(NSPredicate *)filter transform:(NSValueTransformer *)transformer;


@end


