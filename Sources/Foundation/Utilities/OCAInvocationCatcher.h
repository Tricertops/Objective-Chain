//
//  OCAInvocationCatcher.h
//  Objective-Chain
//
//  Created by Martin Kiss on 27.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>





@interface OCAInvocationCatcher : NSProxy



#define OCAInvocationCatch(TARGET, METHOD) \
(OCAInvocation *)({ \
    OCAInvocationCatcher *catcher = [[OCAInvocationCatcher alloc] initWithTarget:(TARGET)]; \
    [(typeof(TARGET))catcher METHOD]; \
    [catcher.invocation retainArguments]; /* This is the reason why you cannot use this invocation with OCAInvoker. */ \
    catcher.invocation; \
}) \



- (instancetype)initWithTarget:(id)target;
@property (nonatomic, readonly, strong) id target;


- (void)forwardInvocation:(NSInvocation *)invocation;
@property (nonatomic, readonly, strong) NSInvocation *invocation;

 //! Argument are retained by this class, not relying on NSInvocation retain.
@property (nonatomic, readonly, strong) NSArray *retainedArguments;



@end







@interface NSInvocation (ObjectArguments)


- (void)oca_enumerateObjectArgumentsUsingBlock:(void(^)(NSUInteger index, id argument))block;


@end


