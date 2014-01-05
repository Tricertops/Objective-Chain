//
//  OCASubscriber.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAObject.h"
#import "OCAConsumer.h"
#import "OCAProducer.h"



typedef void(^OCASubscriberValueHandler)(id value);
typedef void(^OCASubscriberFinishHandler)(NSError *error);





/// Subscriber is concrete Consumer, that can be customized with blocks.
@interface OCASubscriber : OCAObject < OCAConsumer >



- (instancetype)initWithValueHandler:(OCASubscriberValueHandler)valueHandler finishHandler:(OCASubscriberFinishHandler)finishHandler;

+ (instancetype)subscribe:(OCASubscriberValueHandler)valueHandler;
+ (instancetype)subscribe:(OCASubscriberValueHandler)valueHandler finish:(OCASubscriberFinishHandler)finishHandler;



@end





/// Additions to directly subscribe block to a Producer.
@interface OCAProducer (OCASubscriber)


- (OCAConnection *)subscribe:(OCASubscriberValueHandler)valueHandler;
- (OCAConnection *)subscribe:(OCASubscriberValueHandler)valueHandler finish:(OCASubscriberFinishHandler)finishHandler;


@end


