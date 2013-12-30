//
//  OCAConnection.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//
//

#import "OCAObject.h"

@protocol OCAProducer;
@protocol OCAConsumer;





/// Connection represents a data flow from a Provider to Consumer with customizable behavior.
@interface OCAConnection : OCAObject



- (instancetype)initWithProducer:(id<OCAProducer>)producer;
@property (OCA_atomic, readonly, weak) id<OCAProducer> producer;


@property (OCA_atomic, readonly, assign) BOOL closed;
- (void)close;


@property (OCA_atomic, readwrite, strong) NSValueTransformer *transformer;
@property (OCA_atomic, readwrite, strong) NSPredicate *predicate;


@property (OCA_atomic, readwrite, strong) id<OCAConsumer> consumer;



@end
