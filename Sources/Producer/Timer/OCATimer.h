//
//  OCATimer.h
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAProducer.h"





/// Timer is a Producer, that periodically sends current dates.
@interface OCATimer : OCAProducer



#pragma mark Creating Timer

- (instancetype)initWithInterval:(NSTimeInterval)interval;
- (instancetype)initWithDelay:(NSTimeInterval)delay interval:(NSTimeInterval)interval leeway:(NSTimeInterval)leeway count:(NSUInteger)count;
+ (instancetype)timerWithInterval:(NSTimeInterval)interval;
+ (instancetype)timerWithDelay:(NSTimeInterval)delay interval:(NSTimeInterval)interval leeway:(NSTimeInterval)leeway count:(NSUInteger)count;


#pragma mark Attributes of Timer

- (Class)valueClass;
@property (OCA_atomic, readonly, assign) NSTimeInterval delay;
@property (OCA_atomic, readonly, assign) NSTimeInterval interval;
@property (OCA_atomic, readonly, assign) NSTimeInterval leeway;
@property (OCA_atomic, readonly, assign) NSUInteger count;



@end


