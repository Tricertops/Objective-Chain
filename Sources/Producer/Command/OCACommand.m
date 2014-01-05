//
//  OCACommand.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCACommand.h"
#import "OCAProducer+Private.h"










@implementation OCACommand





#pragma mark Creating Command


- (instancetype)init {
    return [super init];
}


+ (instancetype)command {
    return [[self alloc] init];
}





#pragma mark Using Command


- (void)sendValue:(id)value {
    [super produceValue:value];
}


- (void)sendValues:(NSArray *)values {
    for (id object in values) {
        [self sendValue:object];
    }
}


- (void)finishWithError:(NSError *)error {
    [super finishProducingWithError:error];
}





@end


