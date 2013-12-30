//
//  OCAProducer+Protocol.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//
//

#import <Foundation/Foundation.h>
#import "OCAObject.h"

@class OCAConnection;





/// Producer is abstract source of values that are sent to Connections.
@protocol OCAProducer < NSObject >

@required


@property (OCA_atomic, readonly, strong) id lastValue;
@property (OCA_atomic, readonly, assign) BOOL finished;
@property (OCA_atomic, readonly, strong) NSError *error;

@property (OCA_atomic, readonly, strong) NSArray *connections;
- (void)addConnection:(OCAConnection *)connection;
- (void)removeConnection:(OCAConnection *)connection;



@end
