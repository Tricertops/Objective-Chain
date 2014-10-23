//
//  OCALowPassFilter.h
//  Objective-Chain
//
//  Created by Martin Kiss on 23.10.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAMediator.h"
#import "OCAMath.h"



/*! Low-pass filter is used for processing of real-time data with constant frequency. It produces smoother values than it receives.
 *  Low-pass filters are good for animating data that changes very quickly, for example input from accelerometer or similar sensors.
 *  You feed the filter by connecting it to a chain or setting input property. Input may come at any frequency, even irregularly.
 *  You obtain the values by connecting the filter to other Consumer or by observing output property. Output is updated with operating frequency.
 */
@interface OCALowPassFilter : OCAMediator


//TODO: Custom transform/calculation, including point, size, rect.
//TODO: Circular wrap, maybe as transformer.

//! Creates new low-pass filter at 60Hz, with cut-off frequency of fraction * 60Hz.
+ (instancetype)filterWithTolerance:(OCAReal)fraction;

//! Creates new low-pass filter that operates on given frequency. Cut-off frequency is used to soften the input.
- (instancetype)initWithFrequency:(OCAInteger)hertz cutoff:(OCAInteger)hertz;

//! Frequency on which this filter operates. Use 60Hz when you display the output values.
@property (nonatomic, readonly) OCAInteger frequency;
//! Cut-off frequency used to calculate intersteps of output values.
@property (nonatomic, readonly) OCAInteger cutoff;

//! Last value that has passes to the filter. Set this to feed the filter, or use it as a Consumer.
@property (atomic) OCAReal input;
//! Lats value produced by this filter. Read this property, observe it or connecti the filter to other Consumer.
@property (atomic, readonly) OCAReal output;



@end


