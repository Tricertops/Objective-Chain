//
//  OCAConnection+Producer.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//
//

#import "OCAConnection.h"





/// Used by implementors of Producer protocol to propagate values to Connections.
@interface OCAConnection ()



- (void)producerDidProduceValue:(id)value;
- (void)producerDidFinishWithError:(NSError *)error;



@end
