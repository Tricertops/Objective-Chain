//
//  OCAConsumer.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>



/// Consumer is abstract destination of values that are received from Connections.
@protocol OCAConsumer < NSObject >

@required



- (void)consumeValue:(id)value;
- (void)finishConsumingWithError:(NSError *)error;



@end
