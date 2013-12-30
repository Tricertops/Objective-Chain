//
//  OCAConsumer.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//
//

#import "OCASubscriber.h"



@interface OCASubscriber ()


@property (OCA_atomic, readonly, copy) void (^valueHandler)(id value);
@property (OCA_atomic, readonly, copy) void (^finishHandler)(NSError *error);


@end





@implementation OCASubscriber




- (instancetype)initWithValueHandler:(void (^)(id))valueHandler finishHandler:(void (^)(NSError *))finishHandler {
    self = [super init];
    if (self) {
        self->_valueHandler = valueHandler;
        self->_finishHandler = finishHandler;
    }
    return self;
}



- (void)receiveValue:(id)value {
    if (self->_valueHandler) self->_valueHandler(value);
}


- (void)finishWithError:(NSError *)error {
    if (self->_finishHandler) self->_finishHandler(error);
}





@end
