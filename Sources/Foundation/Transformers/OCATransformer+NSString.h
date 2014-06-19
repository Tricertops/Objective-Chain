//
//  OCATransformer+NSString.h
//  Objective-Chain
//
//  Created by Martin Kiss on 10.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer+Base.h"





@interface OCATransformer (NSString)



#pragma mark -
#pragma mark String
#pragma mark -


#pragma mark Creating String

+ (OCATransformer *)stringFromFile;
+ (OCATransformer *)stringFromData;
+ (OCATransformer *)formatString:(NSString *)format;


#pragma mark Getting Substring

+ (OCATransformer *)substringToIndex:(NSInteger)index;
+ (OCATransformer *)substringFromIndex:(NSInteger)index;
+ (OCATransformer *)substringWithRange:(NSRange)range;


#pragma mark Altering String

+ (OCATransformer *)appendFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);
+ (OCATransformer *)trimWhitespace;
+ (OCATransformer *)replaceString:(NSString *)find withString:(NSString *)replace;
+ (OCATransformer *)mutateString:(void(^)(NSMutableString *string))block;
+ (OCATransformer *)capitalizeString;
+ (OCATransformer *)uppercaseString;
+ (OCATransformer *)lowercaseString;


#pragma mark Splitting String

+ (OCATransformer *)splitString:(NSString *)split;
+ (OCATransformer *)splitByWhitespace;



#pragma mark -
#pragma mark Attributed String
#pragma mark -


#pragma mark Creating Attributed String

+ (OCATransformer *)stringWithAttributes:(NSDictionary *)attributes;


#pragma mark Changing Attributes

+ (OCATransformer *)addAttributes:(NSDictionary *)attributes;
+ (OCATransformer *)addAttributes:(NSDictionary *)attributes range:(NSRange)range;
+ (OCATransformer *)transformAttribute:(NSString *)attribute transformer:(NSValueTransformer *)transformer;

#pragma mark Altering Attributed String

+ (OCATransformer *)appendAttributedString:(NSAttributedString *)attributedString;
+ (OCATransformer *)attributedSubstringInRange:(NSRange)range;
+ (OCATransformer *)mutateAttributedString:(void(^)(NSMutableAttributedString *attributedString))block;



#pragma mark -
#pragma mark Number
#pragma mark -


#pragma mark Format Numbers

+ (OCATransformer *)stringWithNumberStyle:(NSNumberFormatterStyle)style fractionDigits:(NSUInteger)fractionalDigits;
+ (OCATransformer *)stringWithNumberFormatter:(NSNumberFormatter *)formatter;
+ (OCATransformer *)stringFromNumber;
+ (OCATransformer *)stringFromCountWithZero:(NSString *)zeroSuffix one:(NSString *)oneSuffix few:(NSString *)fewSuffix many:(NSString *)manySuffix;

#pragma mark Format Byte Count

+ (OCATransformer *)stringWithMemoryByteCount;
+ (OCATransformer *)stringWithFileByteCount;
+ (OCATransformer *)stringWithByteCountFormatter:(NSByteCountFormatter *)formatter;


#pragma mark Parse Numbers

+ (OCATransformer *)numberWithFormatter:(NSNumberFormatter *)formatter;
+ (OCATransformer *)numberFromString;


#pragma mark -
#pragma mark URL
#pragma mark -


#pragma mark Creating URL

+ (OCATransformer *)URLFromString;
+ (OCATransformer *)URLFromPath;
+ (OCATransformer *)URLWithBaseURL:(NSURL *)base;

#pragma mark URL Components

+ (OCATransformer *)componentsOfURL;
+ (OCATransformer *)modifyURLComponents:(void(^)(NSURLComponents *components))block;



@end


