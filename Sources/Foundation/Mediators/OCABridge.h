//
//  OCABridge.h
//  Objective-Chain
//
//  Created by Martin Kiss on 5.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAMediator.h"





@interface OCABridge : OCAMediator



#pragma mark Creating Bridge

- (instancetype)initWithTransformer:(NSValueTransformer *)transformer;

+ (OCABridge *)bridge;
+ (OCABridge *)bridgeForClass:(Class)class;
+ (OCABridge *)bridgeWithTransformer:(NSValueTransformer *)transformer;


@property (atomic, readonly, strong) NSValueTransformer *transformer;


#pragma mark Bridge as a Consumer

- (Class)consumedValueClass;
- (void)consumeValue:(id)value;
- (void)finishConsumingWithError:(NSError *)error;



@end





@interface OCAProducer (OCABridge)


- (OCABridge *)produceTransformed:(NSArray *)transformers CONVENIENCE;
//TODO: Convenience for specific transformer instances.


@end


