//
//  OCAConnection+Private.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//
//

#import "OCAConnection.h"





/// Methods used internally by other classes.
@interface OCAConnection ()



- (void)producerDidProduceValue:(id)value;
- (void)producerDidFinishWithError:(NSError *)error;



@end
