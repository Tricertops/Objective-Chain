//
//  OCAInvocationCatcher.m
//  Objective-Chain
//
//  Created by Martin Kiss on 27.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAInvocationCatcher.h"





@implementation OCAInvocationCatcher





- (instancetype)initWithTarget:(id)target {
    // NSProxy doesn't have -init
    self->_target = target;
    return self;
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [self.target methodSignatureForSelector:selector];
}


- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:nil];
    invocation.target = self.target;
    self->_lastInvocation = invocation;
}





@end


