//
//  OCAInvoker.h
//  Objective-Chain
//
//  Created by Martin Kiss on 27.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAObject.h"
#import "OCAConsumer.h"
#import "OCAProducer.h"





@interface OCAInvoker : OCAObject < OCAConsumer >



- (instancetype)initWithInvocation:(NSInvocation *)invocation;
//TODO: Allow invoking on the value or replace arguments.

@property (atomic, readonly, weak) id target;
@property (atomic, readonly, strong) NSInvocation *invocation;



@end





@interface OCAProducer (OCAInvoker)


- (void)invoke:(NSInvocation *)invocation;
//TODO: -invokeTarget:selector:object:


@end


