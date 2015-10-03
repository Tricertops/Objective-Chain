//
//  OCATransformer+NSDate.m
//  Objective-Chain
//
//  Created by Martin Kiss on 10.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer+NSDate.h"
#import "NSArray+Ordinals.h"





@implementation OCATransformer (NSDate)





#pragma mark -
#pragma mark NSDate
#pragma mark -


+ (OCATransformer *)replaceWithCurrentDate {
    return [[OCATransformer fromClass:nil toClass:[NSDate class] transform:^NSDate *(id input) {
        return [NSDate new];
    } reverse:OCATransformationPass]
            describe:@"replace with current date"];
}





#pragma mark NSDate - Time Interval


+ (OCATransformer *)dateFromTimeIntervalSinceUNIX:(BOOL)unix {
    return [[OCATransformer fromClass:[NSNumber class] toClass:[NSDate class]
                           transform:^NSDate *(NSNumber *input) {
                               if ( ! input) return nil;
                               if (unix)
                                   return [NSDate dateWithTimeIntervalSince1970:input.doubleValue];
                               else
                                   return [NSDate dateWithTimeIntervalSinceReferenceDate:input.doubleValue];
                               
                           } reverse:^NSNumber *(NSDate *input) {
                               if ( ! input) return nil;
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
                                if ( ! input) return @(INFINITY);
                                    
                                return @([input timeIntervalSinceDate:otherDate]);
                                
                            } reverse:^NSDate *(NSNumber *input) {
                                
                                return [otherDate dateByAddingTimeInterval:input.doubleValue];
                            }]
            describe:[NSString stringWithFormat:@"time interval since %@", otherDate]
            reverse:[NSString stringWithFormat:@"date with time interval since %@", otherDate]];
}


+ (OCATransformer *)timeIntervalToDate:(NSDate *)otherDate {
    return [[OCATransformer fromClass:[NSDate class] toClass:[NSNumber class]
                            transform:^NSNumber *(NSDate *input) {
                                if ( ! input) return @(INFINITY);
                                
                                return @([otherDate timeIntervalSinceDate:input]);
                                
                            } reverse:^NSDate *(NSNumber *input) {
                                
                                return [otherDate dateByAddingTimeInterval:input.doubleValue];
                            }]
            describe:[NSString stringWithFormat:@"time interval to %@", otherDate]
            reverse:[NSString stringWithFormat:@"date with time interval to %@", otherDate]];
}


+ (OCATransformer *)timeIntervalSinceMidnight {
    return [[OCATransformer fromClass:[NSDate class] toClass:[NSNumber class]
                            transform:^NSNumber *(NSDate *input) {
                                if ( ! input) return nil;
                                
                                NSDate *midnight = nil;
                                BOOL didIt = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay startDate:&midnight interval:nil forDate:input];
                                if ( ! didIt) return nil;
                                
                                return @( input.timeIntervalSinceReferenceDate - midnight.timeIntervalSinceReferenceDate );
                                
                            } reverse:^NSDate *(NSNumber *input) {
                                if ( ! input) return nil;
                                
                                NSDate *todayMidnight = nil;
                                BOOL didIt = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay startDate:&todayMidnight interval:nil forDate:[NSDate date]];
                                if ( ! didIt) return nil;
                                
                                return [todayMidnight dateByAddingTimeInterval:input.doubleValue];
                            }]
            describe:@"time interval since midnight"
            reverse:@"date from time interval since midnight"];
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
    return [OCATransformer stringWithDateStyle:dateStyle timeStyle:timeStyle relative:NO];
}


+ (OCATransformer *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle relative:(BOOL)doesRelative {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = dateStyle;
    formatter.timeStyle = timeStyle;
    formatter.doesRelativeDateFormatting = doesRelative;
    
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


+ (OCATransformer *)roundDateToUnit:(NSCalendarUnit)unit mode:(NSRoundingMode)mode {
    OCAAssert(mode != NSRoundBankers, @"Bankerz date? Rly?") return nil;
    return [[OCATransformer fromClass:[NSDate class] toClass:[NSDate class]
                            transform:^NSDate *(NSDate *input) {
                                if ( ! input) return nil;
                                
                                NSDate *startDate = nil;
                                NSTimeInterval interval = 0;
                                BOOL succes = [[NSCalendar currentCalendar] rangeOfUnit:unit startDate:&startDate interval:&interval forDate:input];
                                if ( ! succes) return input;
                                
                                switch (mode) {
                                    case NSRoundPlain: {
                                        NSDate *midDate = [startDate dateByAddingTimeInterval:(interval / 2)];
                                        NSComparisonResult comparison = [input compare:midDate];
                                        if (comparison == NSOrderedAscending) return startDate;
                                        else return [startDate dateByAddingTimeInterval:interval];
                                    } break;
                                    case NSRoundDown: return startDate;
                                    case NSRoundUp: return [startDate dateByAddingTimeInterval:interval];
                                    default: break;
                                }
                                return nil;
                                
                            } reverse:OCATransformationPass]
            describe:@"round date"
            reverse:@"pass"];
}





#pragma mark NSDate - Components



+ (OCATransformer *)dateComponents:(NSCalendarUnit)units {
    return [[OCATransformer fromClass:[NSDate class] toClass:[NSDateComponents class]
                            transform:^NSDateComponents *(NSDate *input) {
                                if ( ! input) return nil;
                                
                                return [[NSCalendar currentCalendar] components:units ?: OCACalendarUnitDefault
                                                                       fromDate:input];
                                
                            } reverse:^NSDate *(NSDateComponents *input) {
                                if ( ! input) return nil;
                                
                                return [[NSCalendar currentCalendar] dateFromComponents:input];
                            }]
            describe:@"date components"
            reverse:@"date from components"];
}


+ (OCATransformer *)dateComponents:(NSCalendarUnit)units sinceDate:(NSDate *)otherDate {
    return [[OCATransformer fromClass:[NSDate class] toClass:[NSDateComponents class]
                            transform:^NSDateComponents *(NSDate *input) {
                                if ( ! input) return nil;
                                
                                return [[NSCalendar currentCalendar] components:units ?: OCACalendarUnitDefault
                                                                       fromDate:otherDate
                                                                         toDate:input
                                                                        options:kNilOptions];
                                
                            } reverse:^NSDate *(NSDateComponents *input) {
                                if ( ! input) return nil;
                                
                                return [[NSCalendar currentCalendar] dateByAddingComponents:input toDate:otherDate options:kNilOptions];
                            }]
            describe:[NSString stringWithFormat:@"components since %@", otherDate]
            reverse:[NSString stringWithFormat:@"add components to %@", otherDate]];
}


+ (OCATransformer *)dateComponentsSinceCurrentDate:(NSCalendarUnit)units {
    return [[OCATransformer fromClass:[NSDate class] toClass:[NSDateComponents class]
                            transform:^NSDateComponents *(NSDate *input) {
                                if ( ! input) return nil;
                                
                                return [[NSCalendar currentCalendar] components:units ?: OCACalendarUnitDefault
                                                                       fromDate:[NSDate new]
                                                                         toDate:input
                                                                        options:kNilOptions];
                                
                            } reverse:^NSDate *(NSDateComponents *input) {
                                if ( ! input) return nil;
                                
                                return [[NSCalendar currentCalendar] dateByAddingComponents:input toDate:[NSDate new] options:kNilOptions];
                            }]
            describe:@"components since now"
            reverse:@"add components to now"];
}


+ (OCATransformer *)dateComponentsUntilCurrentDate:(NSCalendarUnit)units {
    return [[OCATransformer fromClass:[NSDate class] toClass:[NSDateComponents class]
                            asymetric:^NSDateComponents *(NSDate *input) {
                                if ( ! input) return nil;
                                
                                return [[NSCalendar currentCalendar] components:units ?: OCACalendarUnitDefault
                                                                       fromDate:input
                                                                         toDate:[NSDate new]
                                                                        options:kNilOptions];
                            }]
            describe:@"components until now"];
}


+ (OCATransformer *)addDateComponents:(NSDateComponents *)components {
    return [[OCATransformer fromClass:[NSDate class] toClass:[NSDate class]
                            asymetric:^NSDate *(NSDate *input) {
                                if ( ! input) return nil;
                                
                                return [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:input options:kNilOptions];
                            }]
            describe:[NSString stringWithFormat:@"date by adding %@", components]];
}


+ (OCATransformer *)modifyDateComponents:(NSCalendarUnit)units block:(void(^)(NSDateComponents *components))block {
    return [[OCATransformer fromClass:[NSDate class] toClass:[NSDate class]
                            asymetric:^NSDate *(NSDate *input) {
                                if ( ! input) return nil;
                                
                                NSDateComponents *components = [[NSCalendar currentCalendar] components:units ?: OCACalendarUnitDefault
                                                                                               fromDate:input];
                                block(components);
                                return [[NSCalendar currentCalendar] dateFromComponents:components];
                            }]
            describe:@"modify date components"];
}


+ (OCATransformer *)dateComponent:(NSCalendarUnit)unit {
    return [[OCATransformer fromClass:[NSDate class] toClass:[NSNumber class]
                           asymetric:^NSNumber *(NSDate *input) {
                               if ( ! input) return nil;
                               
                               NSDateComponents *components = [[NSCalendar currentCalendar] components:unit fromDate:input];
                               NSInteger value = [components oca_valueForUnit:unit];
                               return (value == NSUndefinedDateComponent? nil : @(value));
                           }]
            describe:@"date component from date"];
}


+ (OCATransformer *)nameFromWeekdayShort:(BOOL)shortWeekdays {
    NSDateFormatter *formatter = [NSDateFormatter new];
    NSArray *weekdays = (shortWeekdays?
                         formatter.shortStandaloneWeekdaySymbols
                         : formatter.standaloneWeekdaySymbols);
    
    return [[OCATransformer fromClass:[NSNumber class] toClass:[NSString class]
                            transform:^NSString *(NSNumber *input) {
                                if ( ! input) return nil;
                                NSInteger index = input.unsignedIntegerValue - 1;
                                if (index < 0) return nil;
                                if (index >= weekdays.count) return nil;
                                
                                return [weekdays objectAtIndex:index];
                                
                            } reverse:^NSNumber *(NSString *input) {
                                if ( ! input) return nil;
                                
                                return @([weekdays indexOfObject:input] + 1);
                            }]
            describe:[NSString stringWithFormat:@"%@weekday name", (shortWeekdays? @"short " : @"")]
            reverse:@"weekday index"];
}


+ (OCATransformer *)nameFromMonthShort:(BOOL)shortMonths {
    NSDateFormatter *formatter = [NSDateFormatter new];
    NSArray *months = (shortMonths?
                       formatter.shortStandaloneMonthSymbols
                       : formatter.standaloneMonthSymbols);
    
    return [[OCATransformer fromClass:[NSNumber class] toClass:[NSString class]
                           transform:^NSString *(NSNumber *input) {
                               if ( ! input) return nil;
                               NSInteger index = input.unsignedIntegerValue - 1;
                               if (index < 0) return nil;
                               if (index >= months.count) return nil;
                               
                               return [months objectAtIndex:index];
                               
                           } reverse:^NSNumber *(NSString *input) {
                               if ( ! input) return nil;
                               
                               return @([months indexOfObject:input] + 1);
                           }]
            describe:[NSString stringWithFormat:@"%@month name", (shortMonths? @"short " : @"")]
            reverse:@"month index"];
}





@end





NSCalendarUnit const OCACalendarUnitDefault = (NSCalendarUnitYear
                                               | NSCalendarUnitMonth
                                               | NSCalendarUnitDay
                                               | NSCalendarUnitHour
                                               | NSCalendarUnitMinute
                                               | NSCalendarUnitSecond);





@implementation NSDateComponents (OCATransformer)


- (NSInteger)oca_valueForUnit:(NSCalendarUnit)unit {
    switch (unit) {
        case NSCalendarUnitEra: return self.era;
        case NSCalendarUnitYear: return self.year;
        case NSCalendarUnitMonth: return self.minute;
        case NSWeekCalendarUnit: return self.week;
        case NSCalendarUnitDay: return self.day;
        case NSCalendarUnitHour: return self.hour;
        case NSCalendarUnitMinute: return self.minute;
        case NSCalendarUnitSecond: return self.second;
            
        case NSCalendarUnitWeekday: return self.weekday;
        case NSCalendarUnitWeekdayOrdinal: return self.weekdayOrdinal;
        case NSCalendarUnitQuarter: return self.quarter;
        case NSCalendarUnitWeekOfMonth: return self.weekOfMonth;
        case NSCalendarUnitWeekOfYear: return self.weekOfYear;
        case NSCalendarUnitYearForWeekOfYear: return self.yearForWeekOfYear;
            
        default: return NSUndefinedDateComponent;
    }
}


- (void)oca_setValue:(NSInteger)value forUnit:(NSCalendarUnit)unit {
    switch (unit) {
        case NSCalendarUnitEra: self.era = value; break;
        case NSCalendarUnitYear: self.year = value; break;
        case NSCalendarUnitMonth: self.minute = value; break;
        case NSWeekCalendarUnit: self.week = value; break;
        case NSCalendarUnitDay: self.day = value; break;
        case NSCalendarUnitHour: self.hour = value; break;
        case NSCalendarUnitMinute: self.minute = value; break;
        case NSCalendarUnitSecond: self.second = value; break;
            
        case NSCalendarUnitWeekday: self.weekday = value; break;
        case NSCalendarUnitWeekdayOrdinal: self.weekdayOrdinal = value; break;
        case NSCalendarUnitQuarter: self.quarter = value; break;
        case NSCalendarUnitWeekOfMonth: self.weekOfMonth = value; break;
        case NSCalendarUnitWeekOfYear: self.weekOfYear = value; break;
        case NSCalendarUnitYearForWeekOfYear: self.yearForWeekOfYear = value; break;
            
        default: OCAAssert(NO, @"Cannot set value for this unit.") break;
    }
}


@end


