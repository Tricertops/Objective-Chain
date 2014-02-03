//
//  OCABreakpoint.h
//  Objective-Chain
//
//  Created by Martin Kiss on 3.2.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAMediator.h"





@interface OCABreakpoint : OCAMediator



- (instancetype)initWithSelector:(SEL)breakpointSelector;

- (void)stopBreakpoint;
- (void)soundBreakpoint;



@end





@interface OCAProducer (OCABreakpoint)


- (OCAProducer *)debugStop;
- (OCAProducer *)debugSound;


@end


