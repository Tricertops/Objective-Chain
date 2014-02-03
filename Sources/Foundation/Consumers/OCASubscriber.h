//
//  OCASubscriber.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAObject.h"
#import "OCAConsumer.h"



typedef void(^OCASubscriberValueHandler)(id value);
typedef void(^OCASubscriberFinishHandler)(NSError *error);





/*! Subscriber is concrete universal Consumer, that can be customized using blocks. It is best alternative to implementing your own Consumer class.
 *  NOTE: Since Subscriber uses blocks and is retained by Producers, you have to be careful about retain cycles. Best way to avoid them is not to use Subscriber at all. There may be better alternatives to achieve your goal, for example Invoker or Property can handle many cases without creating retain cycles.
 */
@interface OCASubscriber : OCAObject < OCAConsumer >



#pragma mark Creating Subscriber

//! Designated initializer. Use specific value class to opt-in to class-checking. All arguments may be nil.
- (instancetype)initWithValueClass:(Class)valueClass
                      valueHandler:(OCASubscriberValueHandler)valueHandler
                     finishHandler:(OCASubscriberFinishHandler)finishHandler;

//! Returns new Subscriber, that invokes given block once a value is received, but the value itself is ignored.
+ (instancetype)subscribe:(void(^)(void))handler;

//! Returns new Subscriber with given value class and value handler.
+ (instancetype)subscribeForClass:(Class)valueClass handler:(OCASubscriberValueHandler)valueHandler;

//! Returns new Subscriber with given value class, value handler and finish handler.
+ (instancetype)subscribeForClass:(Class)valueClass handler:(OCASubscriberValueHandler)valueHandler finish:(OCASubscriberFinishHandler)finishHandler;


@property (atomic, readonly, strong) Class consumedValueClass;


@end


