//
//  OCAFoundation+Strings.m
//  Objective-Chain
//
//  Created by Martin Kiss on 10.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAFoundation+Strings.h"





@implementation OCAFoundation (Strings)





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


