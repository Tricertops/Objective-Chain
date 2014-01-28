//
//  OCAInvoker.m
//  Objective-Chain
//
//  Created by Martin Kiss on 27.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAInvoker.h"







@implementation OCAInvoker





- (instancetype)initWithInvocation:(NSInvocation *)invocation {
    self = [super init];
    if (self) {
        OCAAssert(invocation != nil, @"Need invocation");
        
        self->_invocation = invocation;
        self->_target = invocation.target;
        
        self.invocation.target = nil;
    }
    return self;
}


+ (instancetype)invocation:(NSInvocation *)invocation {
    return [[self alloc] initWithInvocation:invocation];
}


- (Class)consumedValueClass {
    return nil;
}


- (void)consumeValue:(id)value {
    [self.invocation invokeWithTarget:self.target];
    self.invocation.target = nil;
}


- (void)finishConsumingWithError:(NSError *)error {
    self->_target = nil;
    self->_invocation = nil;
}





@end










@implementation OCAProducer (OCAInvoker)



- (void)invoke:(NSInvocation *)invocation {
    OCAInvoker *invoker = [[OCAInvoker alloc] initWithInvocation:invocation];
    [self addConsumer:invoker];
}



@end


