//
//  OCASubscriber.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//
//

#import "OCAConsumer.h"





/// Subscriber is concrete Consumer, that can be customized with blocks.
@interface OCASubscriber : OCAConsumer



- (instancetype)initWithValueHandler:(void(^)(id value))valueHandler
                       finishHandler:(void(^)(NSError *error))finishHandler;



@end
