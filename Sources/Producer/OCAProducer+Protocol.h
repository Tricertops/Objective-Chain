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





@protocol OCAProducer < NSObject >

@required



@property (OCA_atomic, readonly, strong) NSArray *connections;
- (void)addConnection:(OCAConnection *)connection;
- (void)removeConnection:(OCAConnection *)connection;



@end
