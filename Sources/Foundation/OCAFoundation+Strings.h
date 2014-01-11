//
//  OCAFoundation+Strings.h
//  Objective-Chain
//
//  Created by Martin Kiss on 10.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAFoundation+Base.h"





@interface OCAFoundation (Strings)



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
+ (OCATransformer *)replaceString:(NSString *)find withString:(NSString *)replace;
+ (OCATransformer *)mutateString:(void(^)(NSMutableString *string))block;


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
#pragma mark Paragraph Style
#pragma mark -

/// Transformators
//TODO: mutateParagraphStyle: (block)


#pragma mark NSNumber

/// Constructors
//TODO: numberWithFormatter:

/// Destructors
//TODO: stringWithNumberFormatter:
//TODO: stringWithNumberStyle:
//TODO: stringWithByteCountFormatter:
//TODO: stringWithMemoryByteCount
//TODO: stringWithFileByteCount


#pragma mark NSURL

/// Constructors
//TODO: URLFromString
//TODO: fileURLFromPath
//TODO: URLWithBaseURL:

/// Destructors
//TODO: URLComponents



@end


