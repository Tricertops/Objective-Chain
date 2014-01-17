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

@property (nonatomic, readwrite, strong) NSDateComponents *components;

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
    
    self.components = [self zeroDateComponents];
    
    self.label = ({
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 3;
        label.frame = CGRectMake(20, 84, 280, label.font.lineHeight * label.numberOfLines);
        
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
             self.timer = [OCATimer repeat:1 owner:self];
             
             [self.timer
              transform:[OCAFoundation dateComponents:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) sinceDate:[NSDate date]]
              connectTo:OCAProperty(self, components, NSDateComponents)];
         }
     }];
    
    
    [OCAProperty(self, components, NSDateComponents)
     transform:[OCATransformer sequence:
                @[
                  [self transformerFromIntervalToStringComponents],
                  [OCAFoundation joinWithString:@"\n"],
                  ]]
     connectTo:OCAProperty(self.label, text, NSString)];
    
}


- (NSDateComponents *)zeroDateComponents {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.second = 0;
    components.minute = 0;
    components.hour = 0;
    return components;
}


- (NSValueTransformer *)transformerFromIntervalToStringComponents {
    return [OCATransformer fromClass:[NSDateComponents class] toClass:[NSArray class]
                    asymetric:^NSArray *(NSDateComponents *components) {
                        
                        NSMutableArray *strings = [[NSMutableArray alloc] init];
                        void(^appendComponent)(NSUInteger, NSString *) = ^(NSUInteger amount, NSString *name){
                            [strings addObject:[NSString stringWithFormat:@"%lu %@%@", (unsigned long)amount, name, (amount == 1? @"":@"s")]];
                        };
                        
                        if (components.hour > 0) appendComponent(components.hour, @"hour");
                        if (components.minute > 0) appendComponent(components.minute, @"minute");
                        appendComponent(MAX(components.second, 0), @"second");
                        
                        return strings;
                    }];
}





@end


