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

+ (instancetype)bridge;
+ (instancetype)bridgeForClass:(Class)class;



@end





@interface OCAProducer (OCABridge)


- (OCABridge *)bridgeWithFilter:(NSPredicate *)filter;
- (OCABridge *)bridgeWithTransform:(NSValueTransformer *)transformer;
- (OCABridge *)bridgeWithFilter:(NSPredicate *)filter transform:(NSValueTransformer *)transformer;


@end


