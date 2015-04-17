//
//  OCAMutableArrayProxy.m
//  Objective-Chain
//
//  Created by Martin Kiss on 17.4.15.
//  Copyright (c) 2015 Martin Kiss. All rights reserved.
//

#import "OCAMutableArrayProxy.h"





@implementation OCAMutableArrayProxy





- (instancetype)initWithReceiver:(NSObject *)receiver accessor:(OCAAccessor *)accessor {
    self->_receiver = receiver;
    self->_accessor = accessor;
    return self;
}


- (NSMutableArray *)asMutableArray {
    return (NSMutableArray *)self;
}





+ (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSMutableArray methodSignatureForSelector:selector];
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSMutableArray instanceMethodSignatureForSelector:selector];
}


- (void)forwardInvocation:(NSInvocation *)invocation {
    NSArray *array = [self.accessor accessObject: self.receiver];
    if ( ! [array isKindOfClass:[NSArray class]]) {
        array = nil;
    }
    NSMutableArray *mutableArray = [array mutableCopy];
    [invocation invokeWithTarget: mutableArray];
    [self.accessor modifyObject: self.receiver withValue: mutableArray];
}





@end


