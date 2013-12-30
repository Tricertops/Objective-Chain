//
//  OCACommand.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//
//

#import "OCAProducer.h"





/// Command is a Producer, that allows explicit sending of values.
@interface OCACommand : OCAProducer



- (void)sendValue:(id)value;
- (void)finishWithError:(NSError *)error;



@end
