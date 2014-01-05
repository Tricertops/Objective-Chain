//
//  OCABridge.h
//  Objective-Chain
//
//  Created by Martin Kiss on 5.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAProducer.h"
#import "OCAConsumer.h"





/// Bridge is a Producer and Consumer, that forwards consumed values.
@interface OCABridge : OCAProducer < OCAConsumer >



#pragma mark Creating Bridge

- (instancetype)init;
+ (instancetype)bridge;



@end


