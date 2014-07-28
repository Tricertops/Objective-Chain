//
//  OCAInterpolator.m
//  Objective-Chain
//
//  Created by Juraj Homola on 24.2.2014.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAInterpolator.h"
#import "OCAProducer+Subclass.h"
#import "OCATimer.h"


@interface OCAInterpolator ()


@property (nonatomic, readwrite, strong) OCATimer *timer;
@property (nonatomic, readwrite, strong) NSDate *initialDate;


@end





@implementation OCAInterpolator


- (instancetype)init {
    return [self initWithDuration:0 frequency:1 fromValue:0 toValue:1];
}

- (instancetype)initWithDuration:(NSTimeInterval)duration
                       frequency:(NSInteger)frequency
                       fromValue:(OCAReal)fromValue
                         toValue:(OCAReal)toValue {
    self = [super initWithValueClass:[NSNumber class]];
    if (self) {
        
        OCAAssert(frequency >= 0, @"Interpolator's frequency must be a non-negative value") return nil;
        OCAAssert(duration >= 0, @"Interpolator's duration must be a non-negative value") return nil;
        
        self->_duration = duration;
        self->_frequency = frequency;
        self->_fromValue = fromValue;
        self->_toValue = toValue;
        
        self.initialDate = [NSDate date];
        
        [self start];
    }
    return self;
}


+ (instancetype)interpolatorWithDuration:(NSTimeInterval)duration frequency:(NSInteger)frequency {
    return [[self alloc] initWithDuration:duration frequency:frequency fromValue:0.0 toValue:1.0];
}

+ (instancetype)interpolatorWithDuration:(NSTimeInterval)duration
                               frequency:(NSInteger)frequency
                               fromValue:(OCAReal)fromValue
                                 toValue:(OCAReal)toValue {
    return [[self alloc] initWithDuration:duration frequency:frequency fromValue:fromValue toValue:toValue];
}



- (void)start {
    
    if (self.duration <= 0 || (self.fromValue == self.toValue)) {
        [self finishWithLastValue:YES];
        return;
    }
    
    
    BOOL isFrequencyZero = (self.frequency == 0);
    
    [self produceValue:@(self.fromValue)];
    
    NSDate *untilDate = [self.initialDate dateByAddingTimeInterval:self.duration];
    if (isFrequencyZero) {
        self.timer = [OCATimer timerForDate:untilDate];
    } else {
        self.timer = [OCATimer timerWithInterval:MIN(1.0/self.frequency, self.duration) untilDate:untilDate];
    }
    
    OCAWeakify(self);
    [self.timer subscribeForClass:[NSNumber class] handler:^(NSNumber *lastFireInterval) {
        OCAStrongify(self);
        
        if ( ! isFrequencyZero) {
            
            OCAReal progress = -self.initialDate.timeIntervalSinceNow / self.duration;
            
            OCAReal producedValue = self.fromValue + (self.toValue - self.fromValue) * progress;
            
            [self produceValue:@(producedValue)];
        }
        
    } finish:^(NSError *error) {
        [self finishWithLastValue:YES];
    }];
    
}

- (void)finishWithLastValue:(BOOL)withLastValue {
    [self.timer stop];
    self.timer = nil;
    if (withLastValue) {
        [self produceValue:@(self.toValue)];
    }
    [self finishProducingWithError:nil];
}


@end
