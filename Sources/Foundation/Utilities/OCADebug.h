//
//  OCADebug.h
//  Objective-Chain
//
//  Created by Martin Kiss on 3.2.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCAProducer.h"



typedef void(^OCADebugBlock)(id);





#define OCADebugStop        ^(id value) { OCABreakpointStop(value); }
extern void OCABreakpointStop(id value);


#define OCADebugSound        ^(id value) { OCABreakpointSound(value); }
extern void OCABreakpointSound(id value);





@interface OCAProducer (OCADebug)


- (OCAProducer *)debug:(OCADebugBlock)block;


@end


