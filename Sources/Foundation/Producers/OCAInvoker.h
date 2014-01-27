//
//  OCAInvoker.h
//  Objective-Chain
//
//  Created by Martin Kiss on 27.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAObject.h"
#import "OCAConsumer.h"
#import "OCAInvocationCatcher.h"
#import "OCAProducer.h"





@interface OCAInvoker : OCAObject < OCAConsumer >


#define OCAInvoker(TARGET, METHOD)  [[OCAInvoker alloc] initWithInvocation:OCAInvocation(TARGET, METHOD)]


- (instancetype)initWithInvocation:(NSInvocation *)invocation;

@property (atomic, readonly, weak) id target;
@property (atomic, readonly, strong) NSInvocation *invocation;



@end





@interface OCAProducer (OCAInvoker)


- (OCAConnection *)invoke:(OCAInvoker *)invoker;


@end


