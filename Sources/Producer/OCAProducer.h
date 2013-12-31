//
//  OCAProducer.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//
//

#import "OCAObject.h"

@class OCAConnection;
@protocol OCAConsumer;





/// Producer is abstract source of values that are sent to Connections.
@interface OCAProducer : OCAObject



@property (OCA_atomic, readonly, strong) id lastValue;
@property (OCA_atomic, readonly, assign) BOOL finished;
@property (OCA_atomic, readonly, strong) NSError *error;


- (OCAConnection *)connectTo:(id<OCAConsumer>)consumer;

@property (OCA_atomic, readonly, strong) NSArray *connections;



@end
