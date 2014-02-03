//
//  OCABreakpoint.m
//  Objective-Chain
//
//  Created by Martin Kiss on 3.2.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCABreakpoint.h"
#import "OCAProducer+Subclass.h"
#import <objc/message.h>





@interface OCABreakpoint ()


@property (atomic, readonly, strong) id receivedValue;
@property (atomic, readonly, assign) SEL selector;


@end










@implementation OCABreakpoint




- (instancetype)initWithSelector:(SEL)breakpointSelector {
    self = [super initWithValueClass:nil];
    if (self) {
        self->_selector = breakpointSelector;
    }
    return self;
}


- (void)consumeValue:(id)value {
    self->_receivedValue = value;
    
    void(*imp)(id, SEL) = (typeof(imp))&objc_msgSend;
    imp(self, self.selector);
    
    [self produceValue:value];
    
    self->_receivedValue = nil;
}




- (void)stopBreakpoint  { /* Use this method for Symbolic Breakpoint. */ }
- (void)soundBreakpoint { /* Use this method for Symbolic Breakpoint. */ }






@end










@implementation OCAProducer (OCABreakpoint)





- (OCAProducer *)debugStop {
    OCABreakpoint *breakpoint = [[OCABreakpoint alloc] initWithSelector:@selector(stopBreakpoint)];
    [self addConsumer:breakpoint];
    return breakpoint;
}


- (OCAProducer *)debugSound {
    OCABreakpoint *breakpoint = [[OCABreakpoint alloc] initWithSelector:@selector(soundBreakpoint)];
    [self addConsumer:breakpoint];
    return breakpoint;
}





@end


