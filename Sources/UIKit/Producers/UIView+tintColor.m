//
//  UIView+tintColor.m
//  Objective-Chain
//
//  Created by Martin Kiss on 17.4.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <objc/runtime.h>
#import "UIView+tintColor.h"
#import "OCASwizzling.h"
#import "OCACommand.h"





@implementation UIView (tintColor)





+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSelector:@selector(tintColorDidChange)
                         with:@selector(oca_tintColorDidChange)];
    });
}


- (void)oca_tintColorDidChange {
    [self oca_tintColorDidChange]; // Calling original implementation.
    
    OCACommand *command = [self oca_tintColorCommandAndCreateIfNone:NO];
    [command sendValue:self.tintColor];
}


- (OCACommand *)oca_tintColorCommandAndCreateIfNone:(BOOL)create {
    OCACommand *command = objc_getAssociatedObject(self, _cmd);
    
    if ( ! command && create) {
        command = [OCACommand commandForClass:[UIColor class]];
        [command sendValue:self.tintColor]; // Initial value.
        objc_setAssociatedObject(self, _cmd, command, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return command;
}


- (OCAProducer *)tintColorProducer {
    return [self oca_tintColorCommandAndCreateIfNone:YES];
}





@end


