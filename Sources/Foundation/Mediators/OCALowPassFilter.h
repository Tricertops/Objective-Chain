//
//  OCALowPassFilter.h
//  Objective-Chain
//
//  Created by Martin Kiss on 23.10.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAMediator.h"
#import "OCAMath.h"
#import "OCAAccessor.h"



/*! Low-pass filter is used for processing of real-time data with constant frequency. It produces smoother values than it receives.
 *  Low-pass filters are good for animating data that changes very quickly, for example input from accelerometer or similar sensors.
 *  You feed the filter by connecting it to a chain or setting input property. Input may come at any frequency, even irregularly.
 *  You obtain the values by connecting the filter to other Consumer or by observing output property. Output is updated with operating frequency.
 *
 *  Low-pass filter typically processes scalar values, but you may also provide class and its accessors to proces structured values.
 *  Example: To process CGPoint values wrapped in NSValue, initialize the instance with NSValue class and accessors for X and Y components.
 *  Processing non-scalar types is more computationally expensive and processed types must conform to NSCopying protocol.
 *  When no accessors are specified, the filter uses -doubleValue method to convert the processed values to scalars.
 */
@interface OCALowPassFilter : OCAMediator


//! Creates new low-pass filter at 60Hz, with cut-off frequency of fraction * 60Hz.
+ (instancetype)filterWithTolerance:(OCAReal)fraction;

//! Creates new low-pass filter that operates on given frequency and processes numbers. Cut-off frequency is used to soften the input.
+ (instancetype)filterWithFrequency:(OCAInteger)hertz cutoff:(OCAInteger)hertz;

//! Creates new low-pass filter that operates on given frequency. You may specify custom class and its accessors that must return NSNumber objects.
- (instancetype)initWithFrequency:(OCAInteger)hertz cutoff:(OCAInteger)hertz fadeNils:(BOOL)fadeNils inputClass:(Class)inputClass accessors:(OCAAccessor *)accessors, ... NS_REQUIRES_NIL_TERMINATION;


//! Frequency on which this filter operates. Use 60Hz when you display the output values.
@property (nonatomic, readonly) OCAInteger frequency;
//! Cut-off frequency used to calculate intersteps of output values.
@property (nonatomic, readonly) OCAInteger cutoff;
//! Whether the filter treats nils as zero values (YES), or it immediately produces nils (NO).
@property (nonatomic, readonly) BOOL fadeNils;
//! Accessors used on input values to obtain numeric components and then used on copy of the input to set them.
@property (nonatomic, readonly) NSArray *accessors;


//! Last value that has passes to the filter. Set this to feed the filter, or use it as a Consumer.
@property (atomic, strong) id<NSCopying> input;
//! Lats value produced by this filter. Read this property, observe it or connecting the filter to other Consumer.
@property (atomic, readonly) id<NSCopying> output;


@end


