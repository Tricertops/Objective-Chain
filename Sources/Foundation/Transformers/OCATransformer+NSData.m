//
//  OCATransformer+NSData.m
//  Objective-Chain
//
//  Created by Martin Kiss on 10.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer+NSData.h"
#import "NSArray+Ordinals.h"





@implementation OCATransformer (NSData)





#pragma mark -
#pragma mark NSData
#pragma mark -


#pragma mark NSData - Create


+ (OCATransformer *)dataFromFile {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSData class]
                            asymetric:^NSData *(NSString *input) {
                                
                                return [NSData dataWithContentsOfFile:input];
                            }]
            describe:@"data from file"];
}


+ (OCATransformer *)dataFromString {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSData class]
                            transform:^NSData *(NSString *input) {
                                
                                return [input dataUsingEncoding:NSUTF8StringEncoding];
                                
                            } reverse:^NSString *(NSData *input) {
                                
                                return [[NSString alloc] initWithData:input encoding:NSUTF8StringEncoding];
                            }]
            describe:@"data from UTF-8 string"
            reverse:@"UTF-8 string from data"];
}


+ (OCATransformer *)subdataWithRange:(NSRange)range {
    return [[OCATransformer fromClass:[NSData class] toClass:[NSData class]
                            transform:^NSData *(NSData *input) {
                                
                                return [input subdataWithRange:OCANormalizeRange(range, input.length)];
                                
                            } reverse:OCATransformationPass]
            
            describe:[NSString stringWithFormat:@"subdata at %@", NSStringFromRange(range)]
            reverse:@"pass"];
}





#pragma mark NSData - Keyed Archivation


+ (OCATransformer *)archiveBinary:(BOOL)binary {
    return [[OCATransformer fromClass:nil toClass:[NSData class]
                            transform:^NSData *(id input) {
                                
                                // Using customized archivation, because of XML option.
                                NSMutableData *output = [[NSMutableData alloc] init];
                                NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:output];
                                archiver.outputFormat = (binary? NSPropertyListBinaryFormat_v1_0 : NSPropertyListXMLFormat_v1_0);
                                [archiver encodeRootObject:input];
                                [archiver finishEncoding];
                                
                                return output;
                                
                            } reverse:^id(NSData *input) {
                                
                                return [NSKeyedUnarchiver unarchiveObjectWithData:input];
                            }]
            describe:[NSString stringWithFormat:@"archive to %@", (binary? @"binary" : @"XML")]
            reverse:@"unarchive"];
}


+ (OCATransformer *)unarchive {
    return [[OCATransformer archiveBinary:YES] reversed];
}





#pragma mark NSData - Property List Serialization


+ (NSData *)serializePropertyList:(id)object binary:(BOOL)binary {
    NSPropertyListFormat format = (binary
                                   ? NSPropertyListBinaryFormat_v1_0
                                   : NSPropertyListXMLFormat_v1_0);
    
    BOOL isValid = [NSPropertyListSerialization propertyList:object isValidForFormat:format];
    if ( ! isValid) return nil;
    
    return [NSPropertyListSerialization dataWithPropertyList:object format:format options:kNilOptions error:nil];
}


+ (id)deserializePropertyList:(NSData *)data mutable:(BOOL)mutable {
    return [NSPropertyListSerialization propertyListWithData:data
                                                     options:(mutable? NSPropertyListMutableContainers : kNilOptions)
                                                      format:nil
                                                       error:nil];
}


+ (OCATransformer *)serializePropertyListBinary:(BOOL)binary {
    return [[OCATransformer fromClass:nil toClass:[NSData class]
                            transform:^NSData *(id input) {
                                
                                return [self serializePropertyList:input binary:binary];
                                
                            } reverse:^id(NSData *input) {
                                
                                return [self deserializePropertyList:input mutable:NO];
                            }]
            describe:[NSString stringWithFormat:@"serialize to %@ property list", (binary? @"binary" : @"XML")]
            reverse:@"deserialize property list"];
}


+ (OCATransformer *)deserializePropertyListMutable:(BOOL)mutable {
    return [[OCATransformer fromClass:[NSData class] toClass:nil
                            transform:^id(NSData *input) {
                                
                                return [self deserializePropertyList:input mutable:mutable];
                                
                            } reverse:^NSData *(id input) {
                                
                                return [self serializePropertyList:input binary:YES];
                            }]
            describe:[NSString stringWithFormat:@"deserialize %@property list", (mutable? @"mutable " : @"")]
            reverse:@"serialize property list"];
}






#pragma mark NSData - JSON Serialization


+ (NSData *)serializeJSON:(id)object pretty:(BOOL)pretty {
    BOOL isValid = [NSJSONSerialization isValidJSONObject:object];
    if ( ! isValid) return nil;
    
    return [NSJSONSerialization dataWithJSONObject:object
                                           options:(pretty? NSJSONWritingPrettyPrinted : kNilOptions)
                                             error:nil];
}


+ (id)deserializeJSON:(NSData *)data mutable:(BOOL)mutable {
    return [NSJSONSerialization JSONObjectWithData:data
                                           options:(mutable? NSJSONReadingMutableContainers : kNilOptions)
                                             error:nil];
}


+ (OCATransformer *)serializeJSONPretty:(BOOL)pretty {
    return [[OCATransformer fromClass:nil toClass:[NSData class]
                            transform:^NSData *(id input) {
                                
                                return [self serializeJSON:input pretty:pretty];
                                
                            } reverse:^id(NSData *input) {
                                
                                return [self deserializeJSON:input mutable:NO];
                            }]
            describe:[NSString stringWithFormat:@"serialize to %@JSON", (pretty? @"pretty " : @"")]
            reverse:@"deserialize JSON"];
}


+ (OCATransformer *)deserializeJSONMutable:(BOOL)mutable {
    return [[OCATransformer fromClass:[NSData class] toClass:nil
                            transform:^id(NSData *input) {
                                
                                return [self deserializeJSON:input mutable:mutable];
                                
                            } reverse:^NSData *(id input) {
                                
                                return [self serializeJSON:input pretty:NO];
                            }]
            describe:[NSString stringWithFormat:@"deserialize %@JSON", (mutable? @"mutable " : @"")]
            reverse:@"serialize JSON"];
}






#pragma mark NSData - Base64 Encoding


+ (OCATransformer *)decodeBase64Data {
    return [[OCATransformer fromClass:[NSData class] toClass:[NSData class]
                            transform:^NSData *(NSData *input) {
                                
                                return [[NSData alloc] initWithBase64EncodedData:input options:kNilOptions];
                                
                            } reverse:^NSData *(NSData *input) {
                                
                                return [input base64EncodedDataWithOptions:kNilOptions];
                            }]
            describe:@"decode base64"
            reverse:@"encode base64"];
}


+ (OCATransformer *)encodeBase64Data {
    return [[OCATransformer decodeBase64Data] reversed];
}





#pragma mark NSData - Hexadecimal Encoding


+ (OCATransformer *)dataFromHex {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSData class]
                            transform:^NSData *(NSString *input) {
                                if ( ! input) return nil;
                                
                                NSArray *ignoringSymbols = @[@"-", @"\n", @" "];
                                for (NSString *symbol in ignoringSymbols) {
                                    input = [input stringByReplacingOccurrencesOfString:symbol withString:@""];
                                }
                                
                                const char *hex = [input cStringUsingEncoding:NSUTF8StringEncoding];
                                NSUInteger length = strlen(hex);
                                NSMutableData *data = [NSMutableData dataWithCapacity:length];
                                
                                char byteHex[3] = { '\0', '\0', '\0'};
                                for (NSUInteger index = 0; index < length/2; index++) {
                                    byteHex[0] = hex[2 * index];
                                    byteHex[1] = hex[2 * index + 1];
                                    
                                    unsigned char byte = strtol(byteHex, NULL, 16);
                                    [data appendBytes:&byte length:1];
                                }
                                
                                return data;
                                
                            } reverse:^NSString *(NSData *input) {
                                if ( ! input) return nil;
                                
                                const unsigned char *data = [input bytes];
                                NSUInteger length  = input.length;
                                NSMutableString *hex  = [NSMutableString stringWithCapacity:(length * 2)];
                                
                                for (int index = 0; index < length; index++) {
                                    [hex appendFormat:@"%02lx", (unsigned long)data[index]];
                                }
                                
                                return hex;
                            }]
            describe:@"data from hex string"
            reverse:@"hex string from data"];
}


+ (OCATransformer *)hexFromData {
    return [[OCATransformer dataFromHex] reversed];
}





#pragma mark -
#pragma mark NSUUID
#pragma mark -



#pragma mark NSUUID - Creating UUID


+ (OCATransformer *)UUIDFromData {
    return [[OCATransformer fromClass:[NSData class] toClass:[NSUUID class]
                            transform:^NSUUID *(NSData *input) {
                                if ( ! input) return nil;
                                
                                uuid_t bytes;
                                [input getBytes:bytes length:sizeof(bytes)];
                                return [[NSUUID alloc] initWithUUIDBytes:bytes];
                                
                            } reverse:^NSData *(NSUUID *input) {
                                if ( ! input) return nil;
                                
                                uuid_t bytes;
                                [input getUUIDBytes:bytes];
                                return [NSData dataWithBytes:bytes length:sizeof(bytes)];
                            }]
            describe:@"UUID from data"
            reverse:@"data from UUID"];
}


+ (OCATransformer *)UUIDFromString {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSUUID class]
                            transform:^NSUUID *(NSString *input) {
                                if ( ! input) return nil;
                                
                                return [[NSUUID alloc] initWithUUIDString:input];
                                
                            } reverse:^NSString *(NSUUID *input) {
                                if ( ! input) return nil;
                                
                                return [input UUIDString];
                            }]
            describe:@"UUID from string"
            reverse:@"string from UUID"];
}





#pragma mark NSUUID - Disposing UUID


+ (OCATransformer *)dataFromUUID {
    return [[OCATransformer UUIDFromData] reversed];
}


+ (OCATransformer *)stringFromUUID {
    return [[OCATransformer UUIDFromString] reversed];
}





@end


