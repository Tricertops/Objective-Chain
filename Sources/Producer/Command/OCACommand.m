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


+ (instancetype)command {
    return [[self alloc] init];
}

+ (instancetype)commandForClass:(Class)valueClass {
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


- (NSString *)description {
    NSString *adjective = (self.finished? @"finished " : @"");
    return [NSString stringWithFormat:@"%@command for %@", adjective, self.valueClass ?: @"anything"];
}


- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@ %p; valueClass = %@; lastValue = %@; finished = %@; error = %@>", self.class, self, self.valueClass, self.lastValue, (self.finished? @"YES" : @"NO"), self.error];
}





@end


