//
//  OCAMediator.m
//  Objective-Chain
//
//  Created by Martin Kiss on 27.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAMediator.h"
#import "OCAProducer+Subclass.h"





@implementation OCAMediator





- (Class)consumedValueClass {
    return nil;
}


- (void)consumeValue:(id)value {
    OCAAssert(NO, @"You can't use this abstract class!") return;
}


- (void)finishConsumingWithError:(NSError *)error {
    OCAAssert(NO, @"You can't use this abstract class!") return;
}





- (void)finishProducingWithError:(NSError *)error {
    if (self.isFinished) return;
    
    if (error) {
        // Errors are fatal, so we finish.
        [super finishProducingWithError:error];
    }
    else {
        // When Producer finished successfully, do nothing there should be more of them. And if not...
    }
}


- (void)dealloc {
    // ... we will finish once deallocated.
    [super finishProducingWithError:nil];
}





@end


