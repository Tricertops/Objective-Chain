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
        label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40];
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
              transform:[OCATransformer sequence:
                         @[
                           [OCAFoundation timeIntervalSinceDate:[NSDate date]],
                           [OCAFoundation stringWithNumberStyle:NSNumberFormatterDecimalStyle fractionDigits:2],
                           ]]
              connectTo:OCAProperty(self.label, text, NSString)];
         }
     }];
    
}





@end


