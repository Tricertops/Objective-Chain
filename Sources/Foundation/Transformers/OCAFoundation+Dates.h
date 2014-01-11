//
//  OCAFoundation+Dates.h
//  Objective-Chain
//
//  Created by Martin Kiss on 10.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAFoundation+Base.h"





@interface OCAFoundation (Dates)



#pragma mark -
#pragma mark Date
#pragma mark -


#pragma mark Working with Time Intervals

+ (OCATransformer *)dateFromTimeIntervalSinceUNIX:(BOOL)unix;
+ (OCATransformer *)timeIntervalSinceUNIX:(BOOL)unix;
+ (OCATransformer *)addTimeInterval:(NSTimeInterval)interval;
+ (OCATransformer *)timeIntervalSinceDate:(NSDate *)otherDate;


#pragma mark Parsing Dates

+ (OCATransformer *)dateWithFormatter:(NSDateFormatter *)formatter;
+ (OCATransformer *)dateFromStringFormat:(NSString *)dateFormat;


#pragma mark Formatting Dates

+ (OCATransformer *)stringWithDateFormatter:(NSDateFormatter *)formatter;
+ (OCATransformer *)stringWithDateFormat:(NSString *)dateFormat;
+ (OCATransformer *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;


#pragma mark Limiting Dates

+ (OCATransformer *)earlierDate:(NSDate *)otherDate;
+ (OCATransformer *)laterDate:(NSDate *)otherDate;


#pragma mark Date Components

+ (OCATransformer *)dateComponents:(NSCalendarUnit)units;
+ (OCATransformer *)dateComponents:(NSCalendarUnit)units sinceDate:(NSDate *)otherDate;
+ (OCATransformer *)addDateComponents:(NSDateComponents *)components;
+ (OCATransformer *)modifyDateComponents:(NSCalendarUnit)units block:(void(^)(NSDateComponents *components))block;



@end


