//
//  OCAPlaceholderObject.m
//  Objective-Chain
//
//  Created by Martin Kiss on 3.2.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAPlaceholderObject.h"
#import <objc/runtime.h>










@implementation OCAPlaceholderObject





+ (instancetype)placeholderForClass:(Class)class {
    static void *OCAPlaceholderObjectKey = &OCAPlaceholderObjectKey;
    OCAPlaceholderObject *placeholder = objc_getAssociatedObject(class, OCAPlaceholderObjectKey);
    if (placeholder) return placeholder;
    
    placeholder = [[self alloc] initWithRepresentedClass:class];
    objc_setAssociatedObject(class, OCAPlaceholderObjectKey, placeholder, OBJC_ASSOCIATION_RETAIN);
    return placeholder;
}


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
    __nonnull id null = nil; // Silences warning on the next line.
    [invocation invokeWithTarget:null];
}





@end


