//
//  OCATimer.h
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//
//

#import "OCAProducer.h"





@interface OCATimer : OCAProducer


- (instancetype)initWithDelay:(NSTimeInterval)delay interval:(NSTimeInterval)interval leeway:(NSTimeInterval)leeway count:(NSUInteger)count;

@property (OCA_atomic, readonly, assign) NSTimeInterval delay;
@property (OCA_atomic, readonly, assign) NSTimeInterval interval;
@property (OCA_atomic, readonly, assign) NSTimeInterval leeway;
@property (OCA_atomic, readonly, assign) NSUInteger count;


@end
