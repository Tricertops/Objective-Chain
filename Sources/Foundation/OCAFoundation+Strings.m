//
//  OCAFoundation+Strings.m
//  Objective-Chain
//
//  Created by Martin Kiss on 10.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAFoundation+Strings.h"
#import "OCAFoundation+Data.h"
#import "OCAFoundation+Collections.m"





@implementation OCAFoundation (Strings)





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
    return [[OCAFoundation dataFromString] reversed];
}


+ (OCATransformer *)formatString:(NSString *)format {
    return [[OCATransformer fromClass:[NSArray class] toClass:[NSString class]
                            asymetric:^NSString *(NSArray *input) {
                                
                                NSMutableString *output = [format mutableCopy];
                                for (NSObject *object in input) {
                                    NSRange range = [output rangeOfString:@"%@"];
                                    [output replaceCharactersInRange:range withString:object.description];
                                }
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
    NSString *string = NSStringFromFormat(format);
    return [[OCATransformer fromClass:[NSString class] toClass:[NSString class]
                           asymetric:^NSString *(NSString *input) {
                               
                               return [input stringByAppendingString:string];
                           }]
            describe:[NSString stringWithFormat:@"append “%@”", string]];
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





#pragma mark NSString - Split


+ (OCATransformer *)splitString:(NSString *)split {
    return [[OCAFoundation joinWithString:split] reversed];
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





@end


