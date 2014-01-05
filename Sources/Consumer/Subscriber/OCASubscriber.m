//
//  OCASubscriber.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCASubscriber.h"





@interface OCASubscriber ()


@property (OCA_atomic, readonly, copy) OCASubscriberValueHandler valueHandler;
@property (OCA_atomic, readonly, copy) OCASubscriberFinishHandler finishHandler;


@end










@implementation OCASubscriber





#pragma mark Creating Subscriber


- (instancetype)init {
    return [self initWithValueHandler:nil finishHandler:nil];
}


- (instancetype)initWithValueHandler:(OCASubscriberValueHandler)valueHandler finishHandler:(OCASubscriberFinishHandler)finishHandler {
    self = [super init];
    if (self) {
        self->_valueHandler = valueHandler;
        self->_finishHandler = finishHandler;
    }
    return self;
}


+ (instancetype)value:(OCASubscriberValueHandler)valueHandler {
    return [[self alloc] initWithValueHandler:valueHandler finishHandler:nil];
}


+ (instancetype)value:(OCASubscriberValueHandler)valueHandler finish:(OCASubscriberFinishHandler)finishHandler {
    return [[self alloc] initWithValueHandler:valueHandler finishHandler:finishHandler];
}





#pragma mark Lifetime of Subscriber


- (void)consumeValue:(id)value {
    if (self->_valueHandler) self->_valueHandler(value);
}


- (void)finishConsumingWithError:(NSError *)error {
    if (self->_finishHandler) self->_finishHandler(error);
}





@end










@implementation OCAProducer (OCASubscriber)



- (OCAConnection *)subscribeValues:(OCASubscriberValueHandler)valueHandler {
    return [self connectTo:[OCASubscriber value:valueHandler]];
}


- (OCAConnection *)subscribeValues:(OCASubscriberValueHandler)valueHandler finish:(OCASubscriberFinishHandler)finishHandler {
    return [self connectTo:[OCASubscriber value:valueHandler finish:finishHandler]];
}



@end


