//
//  OCAProducer.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//
//

#import "OCAObject.h"





/// Producer is abstract source of values that are sent to Connections.
@interface OCAProducer : OCAObject



@property (OCA_atomic, readonly, strong) id lastValue;
@property (OCA_atomic, readonly, assign) BOOL finished;
@property (OCA_atomic, readonly, strong) NSError *error;

@property (OCA_atomic, readonly, strong) NSArray *connections;



@end
