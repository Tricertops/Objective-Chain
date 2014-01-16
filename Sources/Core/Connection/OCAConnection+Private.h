//
//  OCAConnection+Private.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAConnection.h"





/// Methods used internally by other classes.
@interface OCAConnection ()



#pragma mark Production of Values

- (void)producerDidProduceValue:(id)value;
- (void)producerDidFinishWithError:(NSError *)error;



@end
