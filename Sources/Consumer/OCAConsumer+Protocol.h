//
//  OCAConsumer.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//
//

#import <Foundation/Foundation.h>



/// Consumer is abstract destination of values that are received from Connections.
@protocol OCAConsumer < NSObject >

@required



- (void)receiveValue:(id)value;
- (void)finishWithError:(NSError *)error;



@end
