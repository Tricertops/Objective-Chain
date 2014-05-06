//
//  OCASwizzling.m
//  Objective-Chain
//
//  Created by Martin Kiss on 6.5.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <objc/runtime.h>
#import "OCASwizzling.h"





@implementation NSObject (OCASwizzling)





+ (void)swizzleSelector:(SEL)originalSelector with:(SEL)replacementSelector {
    /// http://nshipster.com/method-swizzling/
    
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method replacementMethod = class_getInstanceMethod(self, replacementSelector);
    
    BOOL didAdd = class_addMethod(self,
                                  originalSelector,
                                  method_getImplementation(replacementMethod),
                                  method_getTypeEncoding(replacementMethod));
    if (didAdd) {
        class_replaceMethod(self,
                            replacementSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, replacementMethod);
    }
}





@end


