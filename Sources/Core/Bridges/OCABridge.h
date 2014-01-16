//
//  OCABridge.h
//  Objective-Chain
//
//  Created by Martin Kiss on 5.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAProducer.h"
#import "OCAConsumer.h"





@interface OCABridge : OCAProducer < OCAConsumer >



#pragma mark Creating Bridge

- (instancetype)initWithValueClass:(Class)valueClass;

+ (OCABridge *)bridge;
+ (OCABridge *)bridgeForClass:(Class)class;


#pragma mark Bridge as a Consumer

- (Class)consumedValueClass;
- (void)consumeValue:(id)value;
- (void)finishConsumingWithError:(NSError *)error;



@end





@interface OCAProducer (OCABridge)


- (OCAProducer *)bridgeOn:(OCAQueue *)queue;
- (OCAProducer *)bridgeWithTransform:(NSValueTransformer *)transformer;
- (OCAProducer *)bridgeWithFilter:(NSPredicate *)filter transform:(NSValueTransformer *)transformer;
- (OCAProducer *)bridgeOn:(OCAQueue *)queue filter:(NSPredicate *)filter transform:(NSValueTransformer *)transformer;


@end


