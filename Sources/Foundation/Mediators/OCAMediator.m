//
//  OCAMediator.m
//  Objective-Chain
//
//  Created by Martin Kiss on 27.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAMediator.h"





@implementation OCAMediator





- (Class)consumedValueClass {
    return nil;
}


- (void)consumeValue:(id)value {
    OCAAssert(NO, @"You can't use this abstract class!");
}


- (void)finishConsumingWithError:(NSError *)error {
    OCAAssert(NO, @"You can't use this abstract class!");
}





@end


