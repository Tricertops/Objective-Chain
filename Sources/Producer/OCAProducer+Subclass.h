//
//  OCAProducer+Subclass.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAProducer.h"

@class OCAConnection;





/// Methods used internally by other classes.
@interface OCAProducer ()


#pragma mark Creating Producer

- (instancetype)initWithValueClass:(Class)valueClass;


#pragma mark Managing Connections

- (void)addConnection:(OCAConnection *)connection;
- (void)didAddConnection:(OCAConnection *)connection;

- (void)willRemoveConnection:(OCAConnection *)connection;
- (void)removeConnection:(OCAConnection *)connection;


#pragma mark Lifetime of Producer

- (void)produceValue:(id)value NS_REQUIRES_SUPER;
- (void)finishProducingWithError:(NSError *)error NS_REQUIRES_SUPER;




@end
