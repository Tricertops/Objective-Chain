//
//  OCAProducer.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAObject.h"

@class OCAConnection;
@class OCAQueue;
@protocol OCAConsumer;





/// Producer is abstract source of values that are sent to Connections.
@interface OCAProducer : OCAObject



#pragma mark Getting State of Producer

@property (atomic, readonly, strong) Class valueClass;

@property (atomic, readonly, strong) id lastValue;
@property (atomic, readonly, assign) BOOL finished;
@property (atomic, readonly, strong) NSError *error;


#pragma mark Connecting to Producer

- (OCAConnection *)connectTo:(id<OCAConsumer>)consumer;
- (OCAConnection *)connectOn:(OCAQueue *)queue to:(id<OCAConsumer>)consumer;

- (OCAConnection *)connectWithTransform:(NSValueTransformer *)transformer to:(id<OCAConsumer>)consumer;
- (OCAConnection *)connectOn:(OCAQueue *)queue transform:(NSValueTransformer *)transformer to:(id<OCAConsumer>)consumer;


#pragma mark Inspecting Connections of Producer

@property (atomic, readonly, strong) NSArray *connections;


#pragma mark Describing Producer

- (NSString *)descriptionName;
- (NSDictionary *)debugDescriptionValues;



@end
