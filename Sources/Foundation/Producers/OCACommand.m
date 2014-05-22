//
//  OCACommand.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCACommand.h"
#import "OCAProducer+Subclass.h"










@implementation OCACommand





#pragma mark Creating Command


- (instancetype)initWithValueClass:(Class)valueClass {
    return [super initWithValueClass:valueClass];
}


+ (instancetype)commandForClass:(Class)valueClass {
    return [[self alloc] initWithValueClass:valueClass];
}


+ (void)send:(id)value to:(id<OCAConsumer>)consumer {
    if ( ! consumer) return;
    
    OCACommand *command = [OCACommand commandForClass:[value classForCoder]];
    [command connectTo:consumer];
    [command sendValue:value];
}





#pragma mark Using Command


- (void)sendValue:(id)value {
    [self produceValue:value];
}


- (void)sendValues:(NSArray *)values {
    for (id object in values) {
        [self produceValue:object];
    }
}


- (void)finishWithError:(NSError *)error {
    [self finishProducingWithError:error];
}





@end


