//
//  OCAProducer+Private.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAProducer.h"

@class OCAConnection;





/// Methods used internally by other classes.
@interface OCAProducer ()



- (void)sendValue:(id)value NS_REQUIRES_SUPER;
- (void)finishWithError:(NSError *)error NS_REQUIRES_SUPER;

- (void)addConnection:(OCAConnection *)connection;
- (void)removeConnection:(OCAConnection *)connection;



@end
