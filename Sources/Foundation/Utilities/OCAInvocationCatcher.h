//
//  OCAInvocationCatcher.h
//  Objective-Chain
//
//  Created by Martin Kiss on 27.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>





@interface OCAInvocationCatcher : NSProxy



#define OCAInvocation(TARGET, METHOD) \
(NSInvocation *)({ \
    OCAInvocationCatcher *catcher = [[OCAInvocationCatcher alloc] initWithTarget:(TARGET)]; \
    [(typeof(TARGET))catcher METHOD]; \
    catcher.lastInvocation; \
}) \


- (instancetype)initWithTarget:(id)target;
@property (nonatomic, readonly, strong) id target;


- (void)forwardInvocation:(NSInvocation *)invocation;
@property (nonatomic, readonly, strong) NSInvocation *lastInvocation;



@end


