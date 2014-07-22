//
//  OCATransformer+NSString.m
//  Objective-Chain
//
//  Created by Martin Kiss on 10.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer+NSString.h"
#import "OCATransformer+NSData.h"
#import "OCATransformer+Collections.h"
#import "NSArray+Ordinals.h"
#import "OCAObject.h"
#import "OCAVariadic.h"





@implementation OCATransformer (NSString)





#pragma mark -
#pragma mark NSString
#pragma mark -


#pragma mark NSString - Create


+ (OCATransformer *)stringFromFile {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSString class]
                            asymetric:^NSString *(NSString *input) {
                                
                                return [NSString stringWithContentsOfFile:input encoding:NSUTF8StringEncoding error:nil];
                            }]
            describe:@"string from file"];
}


+ (OCATransformer *)stringFromData {
    return [[OCATransformer dataFromString] reversed];
}


+ (OCATransformer *)formatString:(NSString *)format {
    return [[OCATransformer fromClass:nil toClass:[NSString class]
                            asymetric:^NSString *(id input) {
                                
                                NSArray *array = ( ! input || [input isKindOfClass:[NSArray class]] ? input : @[ input ]);
                                NSMutableString *output = [format mutableCopy];
                                for (NSObject *object in array) {
                                    NSRange range = [output rangeOfString:@"%@"];
                                    if (range.location == NSNotFound) break;
                                    [output replaceCharactersInRange:range withString:(object == NSNull.null? @"" : object.description)];
                                }
                                // Replace the rest, if there is anything left.
                                [output replaceOccurrencesOfString:@"%@" withString:@"—" options:kNilOptions range:NSMakeRange(0, output.length)];
                                return output;
                            }]
            describe:[NSString stringWithFormat:@"format string “%@”", format]];
}





#pragma mark NSString - Substring


+ (OCATransformer *)substringToIndex:(NSInteger)index {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSString class]
                            asymetric:^NSString *(NSString *input) {
                                
                                return [input substringToIndex:OCANormalizeIndex(index, input.length)];
                            }]
            describe:[NSString stringWithFormat:@"substring to %@", @(index)]];
}


+ (OCATransformer *)substringFromIndex:(NSInteger)index {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSString class]
                            asymetric:^NSString *(NSString *input) {
                                
                                return [input substringFromIndex:OCANormalizeIndex(index, input.length)];
                            }]
            describe:[NSString stringWithFormat:@"substring from %@", @(index)]];
}


+ (OCATransformer *)substringWithRange:(NSRange)range {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSString class]
                            asymetric:^NSString *(NSString *input) {
                                
                                return [input substringWithRange:OCANormalizeRange(range, input.length)];
                            }]
            describe:[NSString stringWithFormat:@"substring at %@", NSStringFromRange(range)]];
}





#pragma mark NSString - Alter


+ (OCATransformer *)appendFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2) {
    NSString *string = OCAStringFromFormat(format);
    return [[OCATransformer fromClass:[NSString class] toClass:[NSString class]
                            asymetric:^NSString *(NSString *input) {
                                
                                return [input stringByAppendingString:string];
                            }]
            describe:[NSString stringWithFormat:@"append “%@”", string]];
}


+ (OCATransformer *)trimWhitespace {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSString class]
                            transform:^NSString *(NSString *input) {
                                
                                return [input stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                
                            } reverse:OCATransformationPass]
            describe:@"trim whitespace"
            reverse:@"pass"];
}


+ (OCATransformer *)replaceString:(NSString *)find withString:(NSString *)replace {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSString class]
                            transform:^NSString *(NSString *input) {
                                
                                return [input stringByReplacingOccurrencesOfString:find withString:replace];
                                
                            } reverse:^NSString *(NSString *input) {
                                
                                return [input stringByReplacingOccurrencesOfString:replace withString:find];
                                
                            }]
            describe:[NSString stringWithFormat:@"replace “%@” with “%@”", find, replace]
            reverse:[NSString stringWithFormat:@"replace “%@” with “%@”", replace, find]];
}


+ (OCATransformer *)mutateString:(void(^)(NSMutableString *string))block {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSString class]
                            asymetric:^NSString *(NSString *input) {
                                
                                NSMutableString *mutable = [input mutableCopy];
                                block(mutable);
                                return mutable;
                            }]
            describe:@"mutate string"];
}


+ (OCATransformer *)capitalizeString {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSString class]
                            transform:^NSString *(NSString *input) {
                                if ( ! input) return nil;
                                
                                return [input capitalizedStringWithLocale:nil];
                                
                            } reverse:OCATransformationPass]
            describe:@"capitalize"
            reverse:@"pass"];
}


+ (OCATransformer *)uppercaseString {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSString class]
                            transform:^NSString *(NSString *input) {
                                if ( ! input) return nil;
                                
                                return [input uppercaseStringWithLocale:nil];
                                
                            } reverse:OCATransformationPass]
            describe:@"uppercase"
            reverse:@"pass"];
}


+ (OCATransformer *)lowercaseString {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSString class]
                            transform:^NSString *(NSString *input) {
                                if ( ! input) return nil;
                                
                                return [input lowercaseStringWithLocale:nil];
                                
                            } reverse:OCATransformationPass]
            describe:@"lowercase"
            reverse:@"pass"];
}





#pragma mark NSString - Split


+ (OCATransformer *)splitString:(NSString *)split {
    return [[OCATransformer joinWithString:split] reversed];
}


+ (OCATransformer *)splitByWhitespace {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSArray class]
                            transform:^NSArray *(NSString *input) {
                                
                                return [input componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                
                            } reverse:^NSString *(NSArray *input) {
                                
                                return [input componentsJoinedByString:@" "];
                            }]
            describe:@"split by whitespace"
            reverse:@"join with space"];
}





#pragma mark -
#pragma mark NSAttributedString
#pragma mark -


#pragma mark NSAttributedString - Create


+ (OCATransformer *)stringWithAttributes:(NSDictionary *)attributes {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSAttributedString class]
                            transform:^NSAttributedString *(NSString *input) {
                                if ( ! input) return nil;
                                
                                return [[NSAttributedString alloc] initWithString:input attributes:attributes];
                                
                            } reverse:^NSString *(NSAttributedString *input) {
                                
                                return input.string;
                            }]
            describe:[NSString stringWithFormat:@"attributed with %@", attributes]];
}





#pragma mark NSAttributedString - Attributes


+ (OCATransformer *)addAttributes:(NSDictionary *)attributes {
    return [[OCATransformer fromClass:[NSAttributedString class] toClass:[NSAttributedString class]
                             symetric:^NSAttributedString *(NSAttributedString *input) {
                                 
                                 NSMutableAttributedString *mutable = [input mutableCopy];
                                 [mutable addAttributes:attributes range:NSMakeRange(0, mutable.length)];
                                 return mutable;
                             }]
            describe:[NSString stringWithFormat:@"add attributes %@", attributes]];
}


+ (OCATransformer *)addAttributes:(NSDictionary *)attributes range:(NSRange)range {
    return [[OCATransformer fromClass:[NSAttributedString class] toClass:[NSAttributedString class]
                             symetric:^NSAttributedString *(NSAttributedString *input) {
                                 
                                 NSMutableAttributedString *mutable = [input mutableCopy];
                                 [mutable addAttributes:attributes range:OCANormalizeRange(range, mutable.length)];
                                 return mutable;
                             }]
            describe:[NSString stringWithFormat:@"add attributes %@ at %@", attributes, NSStringFromRange(range)]];
}


+ (NSAttributedString *)transformAttributedString:(NSAttributedString *)string attribute:(NSString *)attribute transformer:(NSValueTransformer *)transformer {
    NSMutableAttributedString *mutable = [string mutableCopy];
    [mutable enumerateAttribute:attribute
                        inRange:NSMakeRange(0, mutable.length)
                        options:kNilOptions
                     usingBlock:^(id value, NSRange range, BOOL *stop) {
                         
                         id transformedValue = [transformer transformedValue:value];
                         [mutable addAttribute:attribute value:transformedValue range:range];
                     }];
    return mutable;
}


+ (OCATransformer *)transformAttribute:(NSString *)attribute transformer:(NSValueTransformer *)transformer {
    NSValueTransformer *reversedTransformer = transformer.reversed;
    return [[OCATransformer fromClass:[NSAttributedString class] toClass:[NSAttributedString class]
                            transform:^NSAttributedString *(NSAttributedString *input) {
                                
                                return [self transformAttributedString:input attribute:attribute transformer:transformer];
                                
                            } reverse:^NSAttributedString *(NSAttributedString *input) {
                                
                                return [self transformAttributedString:input attribute:attribute transformer:reversedTransformer];
                            }]
            describe:[NSString stringWithFormat:@"transform attribute %@ using %@", attribute, transformer]
            reverse:[NSString stringWithFormat:@"transform attribute %@ using %@", attribute, reversedTransformer]];
}





#pragma mark NSAttributedString - Alter


+ (OCATransformer *)appendAttributedString:(NSAttributedString *)attributedString {
    return [[OCATransformer fromClass:[NSAttributedString class] toClass:[NSAttributedString class]
                            transform:^NSAttributedString *(NSAttributedString *input) {
                                
                                NSMutableAttributedString *mutable = [input mutableCopy];
                                [mutable appendAttributedString:attributedString];
                                return mutable;
                                
                            } reverse:OCATransformationPass]
            
            describe:[NSString stringWithFormat:@"append %@", attributedString]
            reverse:@"pass"];
}


+ (OCATransformer *)attributedSubstringInRange:(NSRange)range {
    return [[OCATransformer fromClass:[NSAttributedString class] toClass:[NSAttributedString class]
                            transform:^NSAttributedString *(NSAttributedString *input) {
                                
                                return [input attributedSubstringFromRange:OCANormalizeRange(range, input.length)];
                                
                            } reverse:OCATransformationPass]
            
            describe:[NSString stringWithFormat:@"substring %@", NSStringFromRange(range)]
            reverse:@"pass"];
}


+ (OCATransformer *)mutateAttributedString:(void(^)(NSMutableAttributedString *attributedString))block {
    return [[OCATransformer fromClass:[NSAttributedString class] toClass:[NSAttributedString class]
                            asymetric:^NSAttributedString *(NSAttributedString *input) {
                                
                                NSMutableAttributedString *mutable = [input mutableCopy];
                                block(mutable);
                                return mutable;
                            }]
            describe:@"mutate attributed string"];
}





#pragma mark -
#pragma mark NSNumber
#pragma mark -


#pragma mark NSNumber - Format


+ (OCATransformer *)stringWithNumberStyle:(NSNumberFormatterStyle)style fractionDigits:(NSUInteger)fractionDigits {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = style;
    formatter.minimumFractionDigits = fractionDigits;
    formatter.maximumFractionDigits = fractionDigits;
    NSDictionary *nameByStyle = @{
                                  @(NSNumberFormatterNoStyle): @"format number",
                                  @(NSNumberFormatterDecimalStyle): @"format decimal number",
                                  @(NSNumberFormatterCurrencyStyle): @"format currency",
                                  @(NSNumberFormatterPercentStyle): @"format percent",
                                  @(NSNumberFormatterScientificStyle): @"format scientific number",
                                  @(NSNumberFormatterSpellOutStyle): @"spell out number",
                                  };
    return [[OCATransformer stringWithNumberFormatter:formatter]
            describe:[nameByStyle objectForKey:@(style)]];
}


+ (OCATransformer *)stringWithNumberFormatter:(NSNumberFormatter *)formatter {
    return [[OCATransformer fromClass:[NSNumber class] toClass:[NSString class]
                            transform:^NSString *(NSNumber *input) {
                                
                                return [formatter stringFromNumber:input];
                                
                            } reverse:^NSNumber *(NSString *input) {
                                
                                return [formatter numberFromString:input];
                            }]
            describe:[NSString stringWithFormat:@"format number using %@", formatter]
            reverse:[NSString stringWithFormat:@"parse number using %@", formatter]];
}


+ (OCATransformer *)stringFromNumber {
    return [[OCATransformer fromClass:[NSNumber class] toClass:[NSString class]
                           transform:^NSString *(NSNumber *input) {
                               
                               return input.stringValue;
                               
                           } reverse:^NSNumber *(NSString *input) {
                               
                               if ( ! input.length) return nil;
                               double scannedDouble;
                               NSScanner *scanner = [NSScanner scannerWithString:input];
                               BOOL success = [scanner scanDouble:&scannedDouble];
                               return success ? @(scannedDouble) : nil;
                               
                           }]
            describe:@"string from number"
            reverse:@"number from string"];
}


+ (OCATransformer *)stringFromCountWithZero:(NSString *)zeroSuffix one:(NSString *)oneSuffix few:(NSString *)fewSuffix many:(NSString *)manySuffix {
    return [[OCATransformer fromClass:[NSNumber class] toClass:[NSString class]
                            asymetric:^NSString *(NSNumber *input) {
                                
                                NSInteger count = input.integerValue;
                                NSString *suffix;
                                
                                switch (ABS(count)) {
                                    case 0: suffix = zeroSuffix;  break;
                                    case 1: suffix = oneSuffix;   break;
                                    case 2:
                                    case 3:
                                    case 4: suffix = fewSuffix;   break;
                                    default: suffix = manySuffix; break;
                                }
                                
                                return [NSString stringWithFormat:@"%ld %@", (unsigned long)count, suffix];
                            }]
            describe:@"string from count"];
}





#pragma mark NSNumber - Byte Count


+ (OCATransformer *)stringWithMemoryByteCount {
    NSByteCountFormatter *formatter = [[NSByteCountFormatter alloc] init];
    formatter.countStyle = NSByteCountFormatterCountStyleMemory;
    return [[OCATransformer stringWithByteCountFormatter:formatter]
            describe:@"format memory size"];
}


+ (OCATransformer *)stringWithFileByteCount {
    NSByteCountFormatter *formatter = [[NSByteCountFormatter alloc] init];
    formatter.countStyle = NSByteCountFormatterCountStyleMemory;
    return [[OCATransformer stringWithByteCountFormatter:formatter]
            describe:@"format file size"];
}


+ (OCATransformer *)stringWithByteCountFormatter:(NSByteCountFormatter *)formatter {
    return [[OCATransformer fromClass:[NSNumber class] toClass:[NSString class]
                            asymetric:^NSString *(NSNumber *input) {
                                
                                return [formatter stringFromByteCount:input.longLongValue];
                            }]
            describe:@"format byte count"];
}





#pragma mark NSNumber - Parse


+ (OCATransformer *)numberWithFormatter:(NSNumberFormatter *)formatter {
    return [[OCATransformer stringWithNumberFormatter:formatter] reversed];
}

+ (OCATransformer *)numberFromString {
    return [[OCATransformer stringFromNumber] reversed];
}



#pragma mark -
#pragma mark NSURL
#pragma mark -


#pragma mark NSURL - Create


+ (OCATransformer *)URLFromString {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSURL class]
                            transform:^NSURL *(NSString *input) {
                                if ( ! input) return nil;
                                
                                return [NSURL URLWithString:input];
                                
                            } reverse:^NSString *(NSURL *input) {
                                
                                return [input absoluteString];
                            }]
            describe:@"URL from string"
            reverse:@"string from URL"];
}


+ (OCATransformer *)URLFromPath {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSURL class]
                            transform:^NSURL *(NSString *input) {
                                
                                return [NSURL fileURLWithPath:input];
                                
                            } reverse:^NSString *(NSURL *input) {
                                
                                return [input path];
                            }]
            describe:@"URL from path"
            reverse:@"path from URL"];
}


+ (OCATransformer *)URLWithBaseURL:(NSURL *)base {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSURL class]
                            transform:^NSURL *(NSString *input) {
                                
                                return [NSURL URLWithString:input relativeToURL:base];
                                
                            } reverse:^NSString *(NSURL *input) {
                                
                                return [input relativeString];
                            }]
            describe:[NSString stringWithFormat:@"URL with base “%@”", base]
            reverse:@"relative URL string"];
}





#pragma mark NSURL - Components


+ (OCATransformer *)componentsOfURL {
    return [[OCATransformer fromClass:[NSURL class] toClass:[NSURLComponents class]
                            transform:^NSURLComponents *(NSURL *input) {
                                
                                return [[NSURLComponents alloc] initWithURL:input resolvingAgainstBaseURL:YES];
                                
                            } reverse:^NSURL *(NSURLComponents *input) {
                                
                                return [input URL];
                            }]
            describe:@"components of URL"
            reverse:@"URL from components"];
}


+ (OCATransformer *)modifyURLComponents:(void(^)(NSURLComponents *components))block {
    return [[OCATransformer fromClass:[NSURL class] toClass:[NSURL class]
                            asymetric:^NSURL *(NSURL *input) {
                                
                                NSURLComponents *components = [[NSURLComponents alloc] initWithURL:input resolvingAgainstBaseURL:YES];
                                block(components);
                                return [components URL];
                            }]
            describe:@"modify URL component"];
}





@end


