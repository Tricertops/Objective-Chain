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
    __nonnull id null = nil; // Silences warning on the next line.
    [invocation invokeWithTarget:null];
    invocation.target = self.target;
    self->_invocation = invocation;
    
    [self retainArguments]; //! Because NSInvocation is fucked up.
}


- (void)retainArguments {
    NSMutableArray *retainedArguments = [[NSMutableArray alloc] init];
    [self.invocation oca_enumerateObjectArgumentsUsingBlock:^(NSUInteger index, id argument) {
        if (argument) {
            [retainedArguments addObject:argument];
        }
    }];
    self->_retainedArguments = retainedArguments;
}





@end









@implementation NSInvocation (ObjectArguments)



- (void)oca_enumerateObjectArgumentsUsingBlock:(void(^)(NSUInteger index, id argument))block {
    NSUInteger count = self.methodSignature.numberOfArguments;
    for (NSUInteger index = 0; index < count; index++) {
        
        const char *cType = [self.methodSignature getArgumentTypeAtIndex:index];
        if ([@(cType) isEqualToString:@(@encode(id))]) {
            // Only objects, including target.
            
            __unsafe_unretained id argument = nil;
            [self getArgument:&argument atIndex:index];
            
            block(index, argument);
        }
    }
}



@end


