//
//  OCAErrorRecoveryAttempter.h
//  Objective-Chain
//
//  Created by Martin Kiss on 24.4.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAObject.h"
#import "OCAProducer.h"
#import "OCATransformer.h"


//! Inspired by https://github.com/realmacsoftware/RMErrorRecoveryAttempter



@interface OCAErrorRecoveryAttempter : OCAObject



@property (atomic, readwrite, copy) NSString *failureReason;
@property (atomic, readwrite, copy) NSString *recoverySuggestion;

- (OCAProducer *)addRecoveryOptionWithTitle:(NSString *)title;
- (OCAProducer *)recoveryOptionAtIndex:(NSUInteger)index;

- (NSString *)recoveryOptionTitles;

- (NSError *)recoverableError:(NSError *)error;



@end


