//
//  OCASubscriber.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//
//

#import "OCAObject.h"
#import "OCAConsumer+Protocol.h"
#import "OCAProducer.h"



typedef void(^OCASubscriberValueHandler)(id value);
typedef void(^OCASubscriberFinishHandler)(NSError *error);





/// Subscriber is concrete Consumer, that can be customized with blocks.
@interface OCASubscriber : OCAObject < OCAConsumer >



- (instancetype)initWithValueHandler:(OCASubscriberValueHandler)valueHandler finishHandler:(OCASubscriberFinishHandler)finishHandler;

+ (instancetype)value:(OCASubscriberValueHandler)valueHandler;
+ (instancetype)value:(OCASubscriberValueHandler)valueHandler finish:(OCASubscriberFinishHandler)finishHandler;



@end





/// Additions to directly subscribe block to a Producer.
@interface OCAProducer (OCASubscriber)


- (OCAConnection *)subscribeValues:(OCASubscriberValueHandler)valueHandler;
- (OCAConnection *)subscribeValues:(OCASubscriberValueHandler)valueHandler finish:(OCASubscriberFinishHandler)finishHandler;


@end


