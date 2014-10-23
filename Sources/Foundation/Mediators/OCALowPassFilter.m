//
//  OCALowPassFilter.m
//  Objective-Chain
//
//  Created by Martin Kiss on 23.10.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCALowPassFilter.h"
#import "OCAProducer+Subclass.h"
#import "OCATimer.h"
#import "OCAInvoker.h"





@interface OCALowPassFilter ()


@property (nonatomic, readonly) OCAReal alpha;


@end





@implementation OCALowPassFilter





+ (instancetype)filterWithTolerance:(OCAReal)fraction {
    OCAInteger frequency = 60;
    return [[self alloc] initWithFrequency:frequency cutoff:(frequency * fraction)];
}


- (instancetype)initWithFrequency:(OCAInteger)frequency cutoff:(OCAInteger)cutoff {
    OCAAssert(frequency > 0, @"Low-pass filter need positive frequency") return nil;
    OCAAssert(cutoff > 0, @"Low-pass filter need positive frequency") return nil;
    OCAAssert(frequency > cutoff, @"Low-pass filter need cut-off less than frequency") return nil;
    
    self = [super initWithValueClass:[NSNumber class]];
    if (self) {
        self->_frequency = frequency;
        self->_cutoff = cutoff;
        
        NSTimeInterval interval = 1.0/self.frequency;
        NSTimeInterval tolerance = 1.0/cutoff;
        self->_alpha = interval / (interval + tolerance);
        
        [[OCATimer timerWithInterval:interval owner:self] connectTo:OCAInvocation(self, processValue)];
    }
    return self;
}


- (void)processValue {
    OCAReal alpha = self.alpha;
    OCAReal input = self.input;
    OCAReal previous = self.output;
    
    OCAReal output = input * alpha + previous * (1 - alpha);
    [self produceValue:@(output)];
}


- (OCAReal)output {
    return [self.lastValue doubleValue];
}


OCAKeyPathsAffecting(Output, OCAKP(OCALowPassFilter, lastValue))





- (Class)consumedValueClass {
    return [NSNumber class];
}


- (void)consumeValue:(NSNumber *)value {
    self.input = [value doubleValue];
}





@end


