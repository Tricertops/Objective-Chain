//
//  OCASubscriber.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCASubscriber.h"





@interface OCASubscriber ()


@property (atomic, readonly, copy) OCASubscriberValueHandler valueHandler;
@property (atomic, readonly, copy) OCASubscriberFinishHandler finishHandler;


@end










@implementation OCASubscriber





#pragma mark Creating Subscriber


- (instancetype)init {
    return [self initWithValueClass:nil valueHandler:nil finishHandler:nil];
}


- (instancetype)initWithValueClass:(Class)valueClass
                      valueHandler:(OCASubscriberValueHandler)valueHandler
                     finishHandler:(OCASubscriberFinishHandler)finishHandler {
    self = [super init];
    if (self) {
        self->_consumedValueClass = valueClass;
        self->_valueHandler = valueHandler;
        self->_finishHandler = finishHandler;
    }
    return self;
}


+ (instancetype)subscribe:(void (^)(void))handler {
    return [[self alloc] initWithValueClass:nil
                               valueHandler:^(id value){
                                   handler();
                               }
                              finishHandler:nil];
}


+ (instancetype)subscribeForClass:(Class)valueClass handler:(OCASubscriberValueHandler)valueHandler {
    return [[self alloc] initWithValueClass:valueClass valueHandler:valueHandler finishHandler:nil];
}


+ (instancetype)subscribeForClass:(Class)valueClass handler:(OCASubscriberValueHandler)valueHandler finish:(OCASubscriberFinishHandler)finishHandler {
    return [[self alloc] initWithValueClass:valueClass valueHandler:valueHandler finishHandler:finishHandler];
}





#pragma mark Lifetime of Subscriber


@synthesize consumedValueClass = _consumedValueClass;


- (void)consumeValue:(id)value {
    // Values are validated on Producer's side.
    OCASubscriberValueHandler handler = self.valueHandler;
    if (handler) handler(value);
}


- (void)finishConsumingWithError:(NSError *)error {
    OCASubscriberFinishHandler handler = self.finishHandler;
    if (handler) handler(error);
}





@end


