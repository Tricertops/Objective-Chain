//
//  OCAPlaceholderObject.m
//  Objective-Chain
//
//  Created by Martin Kiss on 3.2.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAPlaceholderObject.h"










@implementation OCAPlaceholderObject





- (instancetype)init {
    return [self initWithRepresentedClass:nil];
}


- (instancetype)initWithRepresentedClass:(Class)class {
    self = [super init];
    if (self) {
        self->_representedClass = class;
    }
    return self;
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [self.representedClass instanceMethodSignatureForSelector:aSelector];
}


- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:nil];
}





@end


