//
//  OCATransformer+NSDate.m
//  Objective-Chain
//
//  Created by Martin Kiss on 10.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer+NSDate.h"





@implementation OCATransformer (NSDate)





#pragma mark -
#pragma mark NSDate
#pragma mark -


#pragma mark NSDate - Time Interval


+ (OCATransformer *)dateFromTimeIntervalSinceUNIX:(BOOL)unix {
    return [[OCATransformer fromClass:[NSNumber class] toClass:[NSDate class]
                           transform:^NSDate *(NSNumber *input) {
                               
                               if (unix)
                                   return [NSDate dateWithTimeIntervalSince1970:input.doubleValue];
                               else
                                   return [NSDate dateWithTimeIntervalSinceReferenceDate:input.doubleValue];
                               
                           } reverse:^NSNumber *(NSDate *input) {
                               
                               if (unix)
                                   return @(input.timeIntervalSince1970);
                               else
                                   return @(input.timeIntervalSinceReferenceDate);
                           }]
            describe:[NSString stringWithFormat:@"date from %@time interval", unix? @"UNIX " : @""]
            reverse:[NSString stringWithFormat:@"%@time interval", unix? @"UNIX " : @""]];
}


+ (OCATransformer *)timeIntervalSinceUNIX:(BOOL)unix {
    return [[OCATransformer dateFromTimeIntervalSinceUNIX:unix] reversed];
}


+ (OCATransformer *)addTimeInterval:(NSTimeInterval)interval {
    return [[OCATransformer fromClass:[NSDate class] toClass:[NSDate class]
                            transform:^NSDate *(NSDate *input) {
                                
                                return [input dateByAddingTimeInterval:interval];
                                
                            } reverse:^NSDate *(NSDate *input) {
                                
                                return [input dateByAddingTimeInterval:-interval];
                            }]
            describe:[NSString stringWithFormat:@"add time interval %@", @(interval)]
            reverse:[NSString stringWithFormat:@"subtract time interval %@", @(-interval)]];
}


+ (OCATransformer *)timeIntervalSinceDate:(NSDate *)otherDate {
    return [[OCATransformer fromClass:[NSDate class] toClass:[NSNumber class]
                            transform:^NSNumber *(NSDate *input) {
                                
                                return @([input timeIntervalSinceDate:otherDate]);
                                
                            } reverse:^NSDate *(NSNumber *input) {
                                
                                return [otherDate dateByAddingTimeInterval:input.doubleValue];
                            }]
            describe:[NSString stringWithFormat:@"time interval since %@", otherDate]
            reverse:[NSString stringWithFormat:@"date with time interval since %@", otherDate]];
}





#pragma mark NSDate - Parse


+ (OCATransformer *)dateWithFormatter:(NSDateFormatter *)formatter {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSDate class]
                           transform:^NSDate *(NSString *input) {
                               
                               return [formatter dateFromString:input];
                               
                           } reverse:^NSString *(NSDate *input) {
                               
                               return [formatter stringFromDate:input];
                           }]
            describe:[NSString stringWithFormat:@"parse date using %@", formatter]
            reverse:[NSString stringWithFormat:@"format date using %@", formatter]];
}


+ (OCATransformer *)dateFromStringFormat:(NSString *)dateFormat {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = dateFormat;
    
    return [[OCATransformer dateWithFormatter:formatter]
            describe:[NSString stringWithFormat:@"parse POSIX date “%@”", dateFormat]
            reverse:[NSString stringWithFormat:@"format POSIX date “%@”", dateFormat]];
}





#pragma mark NSDate - Format


+ (OCATransformer *)stringWithDateFormatter:(NSDateFormatter *)formatter {
    return [[OCATransformer dateWithFormatter:formatter] reversed];
}


+ (OCATransformer *)stringWithDateFormat:(NSString *)dateFormat {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = dateFormat;
    
    return [OCATransformer stringWithDateFormatter:formatter];
}


+ (OCATransformer *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = dateStyle;
    formatter.timeStyle = timeStyle;
    
    return [OCATransformer stringWithDateFormatter:formatter];
}





#pragma mark NSDate - Limits


+ (OCATransformer *)earlierDate:(NSDate *)otherDate {
    return [[OCATransformer fromClass:[NSDate class] toClass:[NSDate class]
                           transform:^NSDate *(NSDate *input) {
                               
                               return [input earlierDate:otherDate];
                               
                           } reverse:OCATransformationPass]
            describe:[NSString stringWithFormat:@"earlier date of %@", otherDate]
            reverse:@"pass"];
}


+ (OCATransformer *)laterDate:(NSDate *)otherDate {
    return [[OCATransformer fromClass:[NSDate class] toClass:[NSDate class]
                            transform:^NSDate *(NSDate *input) {
                                
                                return [input laterDate:otherDate];
                                
                            } reverse:OCATransformationPass]
            describe:[NSString stringWithFormat:@"later date of %@", otherDate]
            reverse:@"pass"];
}





#pragma mark NSDate - Components


+ (NSCalendarUnit)defaultCalendarUnits {
    return (NSCalendarUnitYear
            | NSCalendarUnitMonth
            | NSCalendarUnitDay
            | NSCalendarUnitHour
            | NSCalendarUnitMinute
            | NSCalendarUnitSecond);
}


+ (OCATransformer *)dateComponents:(NSCalendarUnit)units {
    return [[OCATransformer fromClass:[NSDate class] toClass:[NSDateComponents class]
                            transform:^NSDateComponents *(NSDate *input) {
                                
                                return [[NSCalendar currentCalendar] components:units ?: [self defaultCalendarUnits]
                                                                       fromDate:input];
                                
                            } reverse:^NSDate *(NSDateComponents *input) {
                                
                                return [[NSCalendar currentCalendar] dateFromComponents:input];
                            }]
            describe:@"date components"
            reverse:@"date from components"];
}


+ (OCATransformer *)dateComponents:(NSCalendarUnit)units sinceDate:(NSDate *)otherDate {
    return [[OCATransformer fromClass:[NSDate class] toClass:[NSDateComponents class]
                            transform:^NSDateComponents *(NSDate *input) {
                                
                                return [[NSCalendar currentCalendar] components:units ?: [self defaultCalendarUnits]
                                                                       fromDate:otherDate
                                                                         toDate:input
                                                                        options:kNilOptions];
                                
                            } reverse:^NSDate *(NSDateComponents *input) {
                                
                                return [[NSCalendar currentCalendar] dateByAddingComponents:input toDate:otherDate options:kNilOptions];
                            }]
            describe:[NSString stringWithFormat:@"components since %@", otherDate]
            reverse:[NSString stringWithFormat:@"add components to %@", otherDate]];
}


+ (OCATransformer *)addDateComponents:(NSDateComponents *)components {
    return [[OCATransformer fromClass:[NSDate class] toClass:[NSDate class]
                            asymetric:^NSDate *(NSDate *input) {
                                
                                return [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:input options:kNilOptions];
                            }]
            describe:[NSString stringWithFormat:@"date by adding %@", components]];
}


+ (OCATransformer *)modifyDateComponents:(NSCalendarUnit)units block:(void(^)(NSDateComponents *components))block {
    return [[OCATransformer fromClass:[NSDate class] toClass:[NSDate class]
                            asymetric:^NSDate *(NSDate *input) {
                                
                                NSDateComponents *components = [[NSCalendar currentCalendar] components:units ?: [self defaultCalendarUnits]
                                                                                               fromDate:input];
                                block(components);
                                return [[NSCalendar currentCalendar] dateFromComponents:components];
                            }]
            describe:@"modify date components"];
}





@end
