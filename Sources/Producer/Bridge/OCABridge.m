//
//  OCABridge.m
//  Objective-Chain
//
//  Created by Martin Kiss on 5.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCABridge.h"
#import "OCAProducer+Private.h"










@implementation OCABridge





- (void)consumeValue:(id)value {
    [self produceValue:value];
}


- (void)finishConsumingWithError:(NSError *)error {
    [self finishProducingWithError:error];
}





@end
