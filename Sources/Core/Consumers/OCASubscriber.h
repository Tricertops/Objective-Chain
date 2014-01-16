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



typedef void(^OCASubscriberEventHandler)(void);
typedef void(^OCASubscriberValueHandler)(id value);
typedef void(^OCASubscriberFinishHandler)(NSError *error);





/// Subscriber is concrete Consumer, that can be customized with blocks.
@interface OCASubscriber : OCAObject < OCAConsumer >



#pragma mark Creating Subscriber

- (instancetype)initWithValueClass:(Class)valueClass valueHandler:(OCASubscriberValueHandler)valueHandler finishHandler:(OCASubscriberFinishHandler)finishHandler;

+ (instancetype)events:(OCASubscriberEventHandler)eventHandler;
+ (instancetype)class:(Class)valueClass handler:(OCASubscriberValueHandler)valueHandler;
+ (instancetype)class:(Class)valueClass handler:(OCASubscriberValueHandler)valueHandler finish:(OCASubscriberFinishHandler)finishHandler;


#pragma mark Attributes of Subscriber

@property (atomic, readonly, strong) Class valueClass;



@end





/// Additions to directly subscribe block to a Producer.
@interface OCAProducer (OCASubscriber)


- (OCAConnection *)subscribeEvents:(OCASubscriberEventHandler)eventHandler;
- (OCAConnection *)subscribe:(Class)valueClass handler:(OCASubscriberValueHandler)valueHandler;
- (OCAConnection *)subscribe:(Class)valueClass handler:(OCASubscriberValueHandler)valueHandler finish:(OCASubscriberFinishHandler)finishHandler;


@end


