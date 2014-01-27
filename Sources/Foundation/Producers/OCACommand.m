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


+ (instancetype)command {
    return [[self alloc] init];
}

+ (instancetype)class:(Class)valueClass {
    return [[self alloc] initWithValueClass:valueClass];
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





#pragma mark Describing Command


- (NSString *)descriptionName {
    return @"Command";
}





@end


