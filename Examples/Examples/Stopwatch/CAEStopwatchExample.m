//
//  CAEStopwatchExample.m
//  Chain Examples
//
//  Created by Martin Kiss on 17.1.14.
//  Copyright (c) 2014 iMartin Kiss. All rights reserved.
//

#import "CAEStopwatchExample.h"





@interface CAEStopwatchExample ()


@property (nonatomic, readwrite, strong) OCATimer *timer;

@property (nonatomic, readwrite, assign) NSTimeInterval interval;

@property (nonatomic, readwrite, strong) UILabel *label;


@end










@implementation CAEStopwatchExample





#pragma mark Example Info & Registration


+ (void)load {
    [self registerExample];
}


+ (NSString *)exampleTitle {
    return @"Stopwatch";
}


+ (NSString *)exampleSubtitle {
    return @"Timer with date transforms";
}


+ (NSString *)exampleDescription {
    return @"";
}


+ (NSString *)exampleAuthor {
    return @"iMartin Kiss";
}


+ (NSDate *)exampleDate {
    return [self day:17 month:1 year:2014];
}





#pragma mark Setup


- (void)setupViews {
    [super setupViews];
    
    self.label = ({
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:80];
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumScaleFactor = 0.5;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor clearColor];
        label.frame = CGRectMake(20, 84, 280, label.font.lineHeight);
        
        [self.view addSubview:label];
        label;
    });
}


- (void)setupConnections {
    [super setupConnections];
    
    OCAWeakify(self);
    
    [OCAProperty(self, fullyVisible, BOOL)
     subscribe:[NSNumber class]
     handler:^(NSNumber *value) {
         OCAStrongify(self);
         BOOL fullyVisible = value.boolValue;
         
         [self.timer stop];
         if (fullyVisible) {
             self.timer = [OCATimer repeat:0.01 owner:self];
             
             [self.timer
              transform:[OCAFoundation timeIntervalSinceDate:[NSDate date]]
              connectTo:OCAProperty(self, interval, NSTimeInterval)];
         }
     }];
    
    
    [OCAProperty(self, interval, NSTimeInterval)
     transform:[self transformerFromIntervalToString]
     connectTo:OCAProperty(self.label, text, NSString)];
    
}


- (NSValueTransformer *)transformerFromIntervalToString {
    return [OCATransformer fromClass:[NSNumber class] toClass:[NSString class]
                    asymetric:^NSString *(NSNumber *intervalNumber) {
                        NSTimeInterval time = intervalNumber.doubleValue;
                        
                        NSUInteger hours = floor(time / 3600);
                        time -= hours * 3600;
                        NSUInteger minutes = floor(time / 60);
                        time -= minutes * 60;
                        NSUInteger seconds = floor(time);
                        time -= seconds;
                        NSUInteger fractions = floor(time * 100);
                        
                        if (hours) return [NSString stringWithFormat:@"%lu:%02lu:%02lu.%02lu", hours, minutes, seconds, fractions];
                        else if (minutes) return [NSString stringWithFormat:@"%lu:%02lu.%02lu", minutes, seconds, fractions];
                        else return [NSString stringWithFormat:@"%lu.%02lu", seconds, fractions];
                    }];
}





@end


