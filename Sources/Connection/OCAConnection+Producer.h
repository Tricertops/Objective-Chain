//
//  OCAConnection+Producer.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//
//

#import "OCAConnection.h"





@interface OCAConnection ()



- (void)producer:(id<OCAProducer>)producer didSendValue:(id)value;
- (void)producer:(id<OCAProducer>)producer didFinishWithError:(NSError *)error;



@end
