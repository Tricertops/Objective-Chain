//
//  UIView+tintColor.m
//  Objective-Chain
//
//  Created by Martin Kiss on 17.4.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "UIView+tintColor.h"
#import <objc/runtime.h>
#import "OCACommand.h"





@implementation UIView (tintColor)





+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /// http://nshipster.com/method-swizzling/
        
        SEL originalSelector = @selector(tintColorDidChange);
        SEL swizzledSelector = @selector(oca_tintColorDidChange);
        
        Method originalMethod = class_getInstanceMethod(self, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(self,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(self,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}


- (void)oca_tintColorDidChange {
    OCACommand *tintColorCommand = (OCACommand *)self.tintColorProducer;
    [tintColorCommand sendValue:self.tintColor];
}


- (OCAProducer *)tintColorProducer {
    OCACommand *command = objc_getAssociatedObject(self, _cmd);
    if ( ! command) {
        command = [OCACommand commandForClass:[UIColor class]];
        objc_setAssociatedObject(self, _cmd, command, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return command;
}





@end


