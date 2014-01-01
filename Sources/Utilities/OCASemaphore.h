//
//  OCASemaphore.h
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAObject.h"





/// Simple wrapper of GCD semaphore.
@interface OCASemaphore : OCAObject



- (instancetype)initWithValue:(NSUInteger)integer;

- (void)signal;

- (void)wait;
- (BOOL)waitFor:(NSTimeInterval)interval;
- (BOOL)waitUntil:(NSDate *)date;



@end
