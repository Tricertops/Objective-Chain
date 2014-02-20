//
//  OCADebug.m
//  Objective-Chain
//
//  Created by Martin Kiss on 3.2.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCADebug.h"
#import "OCABridge.h"
#import "OCATransformer+Core.h"





extern void OCABreakpointStop(id value) {
    /*
     *  This function is used for Symbolic Breakpoint.
     *  If you stopped here, you can see the `value`, that was send from Producer to Consumer.
     *  You can navigate up in the stack trace and you will see the the place where this happened.
     */
}


extern void OCABreakpointSound(id value) {
    /*
     *  This function is used for Symbolic Breakpoint.
     */
}





@implementation OCAProducer (OCADebug)



- (OCAProducer *)debug:(OCADebugBlock)block {
    OCABridge *debugBridge = [[OCABridge alloc] initWithTransformer:[OCATransformer sideEffect:block]];
    [self addConsumer:debugBridge];
    return debugBridge;
}



@end


