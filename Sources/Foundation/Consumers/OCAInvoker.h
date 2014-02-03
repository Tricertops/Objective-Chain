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
#import "OCAPlaceholderObject.h"





@interface OCAInvoker : OCAObject < OCAConsumer >



- (instancetype)initWithInvocation:(NSInvocation *)invocation;

+ (instancetype)invoke:(NSInvocation *)invocation;


@property (atomic, readonly, weak) id target;

@property (atomic, readonly, strong) NSInvocation *invocation;


- (void)invokeWithSubstitutions:(NSArray *)substitutions;



@end


