//
//  OCATransformer+NSDate.h
//  Objective-Chain
//
//  Created by Martin Kiss on 10.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer+Base.h"





@interface OCATransformer (NSDate)



#pragma mark -
#pragma mark Date
#pragma mark -


+ (OCATransformer *)replaceWithCurrentDate;


#pragma mark Working with Time Intervals

+ (OCATransformer *)dateFromTimeIntervalSinceUNIX:(BOOL)unix;
+ (OCATransformer *)timeIntervalSinceUNIX:(BOOL)unix;
+ (OCATransformer *)addTimeInterval:(NSTimeInterval)interval;
+ (OCATransformer *)timeIntervalSinceDate:(NSDate *)otherDate;
+ (OCATransformer *)timeIntervalToDate:(NSDate *)otherDate;
+ (OCATransformer *)timeIntervalSinceMidnight;


#pragma mark Parsing Dates

+ (OCATransformer *)dateWithFormatter:(NSDateFormatter *)formatter;
+ (OCATransformer *)dateFromStringFormat:(NSString *)dateFormat;


#pragma mark Formatting Dates

+ (OCATransformer *)stringWithDateFormatter:(NSDateFormatter *)formatter;
+ (OCATransformer *)stringWithDateFormat:(NSString *)dateFormat;
+ (OCATransformer *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;
+ (OCATransformer *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle relative:(BOOL)doesRelative;


#pragma mark Limiting Dates

+ (OCATransformer *)earlierDate:(NSDate *)otherDate;
+ (OCATransformer *)laterDate:(NSDate *)otherDate;
+ (OCATransformer *)roundDateToUnit:(NSCalendarUnit)unit mode:(NSRoundingMode)mode;


#pragma mark Date Components

+ (OCATransformer *)dateComponents:(NSCalendarUnit)units;
+ (OCATransformer *)dateComponents:(NSCalendarUnit)units sinceDate:(NSDate *)otherDate;
+ (OCATransformer *)dateComponentsSinceCurrentDate:(NSCalendarUnit)units;
+ (OCATransformer *)dateComponentsUntilCurrentDate:(NSCalendarUnit)units;
+ (OCATransformer *)addDateComponents:(NSDateComponents *)components;
+ (OCATransformer *)modifyDateComponents:(NSCalendarUnit)units block:(void(^)(NSDateComponents *components))block;
+ (OCATransformer *)dateComponent:(NSCalendarUnit)unit;
+ (OCATransformer *)nameFromWeekdayShort:(BOOL)shortWeekdays;
+ (OCATransformer *)nameFromMonthShort:(BOOL)shortMonths;



@end






extern NSCalendarUnit const OCACalendarUnitDefault;



@interface NSDateComponents (OCATransformer)

- (NSInteger)oca_valueForUnit:(NSCalendarUnit)unit;
- (void)oca_setValue:(NSInteger)value forUnit:(NSCalendarUnit)unit;

@end


