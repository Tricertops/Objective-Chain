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
#import "OCAVariadic.h"





@interface OCALowPassFilter ()


@property (nonatomic, readonly) OCAReal alpha;


@end





@implementation OCALowPassFilter





+ (instancetype)filterWithTolerance:(OCAReal)fraction {
    OCAInteger frequency = 60;
    return [[self alloc] initWithFrequency:frequency cutoff:(frequency * fraction) fadeNils:YES inputClass:nil accessors:nil];
}


+ (instancetype)filterWithFrequency:(OCAInteger)frequency cutoff:(OCAInteger)cutoff {
    return [[self alloc] initWithFrequency:frequency cutoff:cutoff fadeNils:YES inputClass:nil accessors:nil];
}


- (instancetype)initWithFrequency:(OCAInteger)frequency cutoff:(OCAInteger)cutoff fadeNils:(BOOL)fadeNils inputClass:(__unsafe_unretained Class)inputClass accessors:(OCAAccessor *)accessors, ... {
    OCAAssert(frequency > 0, @"Low-pass filter need positive frequency") return nil;
    OCAAssert(cutoff > 0, @"Low-pass filter need positive frequency") return nil;
    OCAAssert(frequency > cutoff, @"Low-pass filter need cut-off less than frequency") return nil;
    
    self = [super initWithValueClass:inputClass];
    if (self) {
        self->_frequency = frequency;
        self->_cutoff = cutoff;
        self->_fadeNils = fadeNils;
        self->_accessors = OCAArrayFromVariadicArguments(accessors);
        
        NSTimeInterval interval = 1.0/self.frequency;
        NSTimeInterval tolerance = 1.0/cutoff;
        self->_alpha = interval / (interval + tolerance);
        
        [[OCATimer timerWithInterval:interval owner:self] connectTo:OCAInvocation(self, processValue)];
    }
    return self;
}


- (Class)consumedValueClass {
    return self.valueClass;
}


- (void)consumeValue:(id<NSCopying>)value {
    self.input = value;
}


- (id<NSCopying>)output {
    return self.lastValue;
}


OCAKeyPathsAffecting(Output, OCAKP(OCALowPassFilter, lastValue))





- (void)processValue {
    id input = self.input;
    id previous = self.output;
    id output = nil;
    
    if (input && previous) {
            output = [self outputForPrevious:previous input:input];
    }
    else if (input || previous) {
        if (self.fadeNils) {
            output = [self outputForPrevious:previous input:input];
        }
        else {
            output = [input copy];
        }
    }
    
    [self produceValue:output];
}


- (NSObject<NSCopying> *)outputForPrevious:(NSObject<NSCopying> *)previous input:(NSObject<NSCopying> *)input {
    id output = [input copy];
    OCAReal alpha = self.alpha;
    
    if (self.accessors.count) {
        for (OCAAccessor *accessor in self.accessors) {
            OCAReal inputComponent = [[accessor accessObject:input] doubleValue];
            OCAReal previousComponent = [[accessor accessObject:previous] doubleValue];
            
            OCAReal outputComponent = [self outputForPrevious:previousComponent input:inputComponent alpha:alpha];
            
            output = [accessor modifyObject:output withValue:@(outputComponent)];
        }
    }
    else {
        OCAReal outputComponent = [self outputForPrevious:[(id)previous doubleValue] input:[(id)input doubleValue] alpha:alpha];
        output = @(outputComponent);
    }
    return output;
}


- (OCAReal)outputForPrevious:(OCAReal)previous input:(OCAReal)input alpha:(OCAReal)alpha {
    return input * alpha + previous * (1 - alpha);
}





@end


