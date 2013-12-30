//
//  OCASubscriber.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//
//

#import "OCAObject.h"
#import "OCAConsumer+Protocol.h"





/// Subscriber is concrete Consumer, that can be customized with blocks.
@interface OCASubscriber : OCAObject < OCAConsumer >



- (instancetype)initWithValueHandler:(void(^)(id value))valueHandler
                       finishHandler:(void(^)(NSError *error))finishHandler;



@end
