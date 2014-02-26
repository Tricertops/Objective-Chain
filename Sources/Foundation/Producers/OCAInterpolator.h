//
//  OCAInterpolator.h
//  Objective-Chain
//
//  Created by Juraj Homola on 24.2.2014.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAProducer.h"
#import "OCAMath.h"



@interface OCAInterpolator : OCAProducer


/// Designated initializer
- (instancetype)initWithDuration:(NSTimeInterval)duration
                       frequency:(NSInteger)frequency
                       fromValue:(OCAReal)fromValue
                         toValue:(OCAReal)toValue;


/// Interpolates between 0 and 1.
+ (instancetype)interpolatorWithDuration:(NSTimeInterval)duration frequency:(NSInteger)frequency;


/// Interpolates between specific values.
+ (instancetype)interpolatorWithDuration:(NSTimeInterval)duration
                               frequency:(NSInteger)frequency
                               fromValue:(OCAReal)fromValue
                                 toValue:(OCAReal)toValue;


/// Duration for which the interpolator is producing it's respective values. Must be non-negative.
@property (nonatomic, readonly, assign) NSTimeInterval duration;

/// Indicates how many values are produced per one second. Must be non-negative.
@property (nonatomic, readonly, assign) NSInteger frequency;

/// Value that is interpolated from.
@property (nonatomic, readonly, assign) OCAReal fromValue;

/// Value that is interpolated to.
@property (nonatomic, readonly, assign) OCAReal toValue;


/// Stops the interpolator and if the BOOL is YES - produces the last value.
- (void)finishWithLastValue:(BOOL)withLastValue;


@end
