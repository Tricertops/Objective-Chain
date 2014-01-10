//
//  OCAFoundation+Data.m
//  Objective-Chain
//
//  Created by Martin Kiss on 10.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAFoundation+Data.h"





@implementation OCAFoundation (Data)





#pragma mark NSData


+ (OCATransformer *)dataFromFile {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSData class] asymetric:^NSData *(NSString *input) {
        if ( ! input) return nil;
        return [NSData dataWithContentsOfFile:input];
    }]
            describe:@"data from file"];
}


+ (OCATransformer *)dataFromString {
    return [[OCATransformer fromClass:[NSString class] toClass:[NSData class] transform:^NSData *(NSString *input) {
        return [input dataUsingEncoding:NSUTF8StringEncoding];
    } reverse:^NSString *(NSData *input) {
        if ( ! input) return nil;
        return [[NSString alloc] initWithData:input encoding:NSUTF8StringEncoding];
    }]
            describe:@"data from string"
            reverse:@"string from data"];
}


+ (OCATransformer *)archiveBinary:(BOOL)binary {
    return [[OCATransformer fromClass:nil toClass:[NSData class] transform:^NSData *(id input) {
        if ( ! input) return nil;
        NSMutableData *output = [[NSMutableData alloc] init];
        
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:output];
        archiver.outputFormat = (binary? NSPropertyListBinaryFormat_v1_0 : NSPropertyListXMLFormat_v1_0);
        [archiver encodeRootObject:input];
        [archiver finishEncoding];
        
        return output;
    } reverse:^id(NSData *input) {
        if ( ! input) return nil;
        return [NSKeyedUnarchiver unarchiveObjectWithData:input];
    }]
            describe:[NSString stringWithFormat:@"archive to %@", (binary? @"binary" : @"XML")]
            reverse:@"unarchive"];
}


+ (OCATransformer *)serializePropertyListBinary:(BOOL)binary {
    return [[OCATransformer fromClass:nil toClass:[NSData class] transform:^NSData *(id input) {
        if ( ! input) return nil;
        
        NSPropertyListFormat format = (binary? NSPropertyListBinaryFormat_v1_0 : NSPropertyListXMLFormat_v1_0);
        BOOL isValid = [NSPropertyListSerialization propertyList:input isValidForFormat:format];
        if ( ! isValid) return nil;
        
        return [NSPropertyListSerialization dataWithPropertyList:input format:format options:kNilOptions error:nil];
    } reverse:^id(NSData *input) {
        if ( ! input) return nil;
        return [NSPropertyListSerialization propertyListWithData:input options:kNilOptions format:nil error:nil];
    }]
            describe:[NSString stringWithFormat:@"serialize to %@ property list", (binary? @"binary" : @"XML")]
            reverse:@"deserialize property list"];
}


+ (OCATransformer *)serializeJSONPretty:(BOOL)pretty {
    return [[OCATransformer fromClass:nil toClass:[NSData class] transform:^NSData *(id input) {
        if ( ! input) return nil;
        
        BOOL isValid = [NSJSONSerialization isValidJSONObject:input];
        if ( ! isValid) return nil;
        
        return [NSJSONSerialization dataWithJSONObject:input options:(pretty? NSJSONWritingPrettyPrinted : kNilOptions) error:nil];
    } reverse:^id(NSData *input) {
        if ( ! input) return nil;
        return [NSJSONSerialization JSONObjectWithData:input options:kNilOptions error:nil];
    }]
            describe:[NSString stringWithFormat:@"serialize to %@JSON", (pretty? @"pretty " : @"")]
            reverse:@"deserialize JSON"];
}


+ (OCATransformer *)decodeBase64Data {
    return [[OCATransformer fromClass:[NSData class] toClass:[NSData class] transform:^NSData *(NSData *input) {
        if ( ! input) return nil;
        return [[NSData alloc] initWithBase64EncodedData:input options:kNilOptions];
    } reverse:^NSData *(NSData *input) {
        if ( ! input) return nil;
        return [input base64EncodedDataWithOptions:kNilOptions];
    }]
            describe:@"decode base64"
            reverse:@"encode base64"];
}


+ (OCATransformer *)encodeBase64Data {
    return [[OCAFoundation decodeBase64Data] reversed];
}


+ (OCATransformer *)subdataWithRange:(NSRange)range {
    return [[OCATransformer fromClass:[NSData class] toClass:[NSData class] transform:^NSData *(NSData *input) {
        
        NSUInteger location = CLAMP(0, range.location, input.length);
        NSUInteger length = CLAMP(0, range.length, input.length - location);
        
        return [input subdataWithRange:NSMakeRange(location, length)];
    } reverse:OCATransformationPass]
            describe:[NSString stringWithFormat:@"subdata at %@", NSStringFromRange(range)]
            reverse:@"pass"];
}


+ (OCATransformer *)unarchive {
    return [[OCAFoundation archiveBinary:YES] reversed];
}


+ (OCATransformer *)deserializePropertyListMutable:(BOOL)mutable {
    return [[OCATransformer fromClass:[NSData class] toClass:nil transform:^id(NSData *input) {
        if ( ! input) return nil;
        return [NSPropertyListSerialization propertyListWithData:input options:(mutable? NSPropertyListMutableContainers : kNilOptions) format:nil error:nil];
    } reverse:^NSData *(id input) {
        if ( ! input) return nil;
        
        BOOL isValid = [NSPropertyListSerialization propertyList:input isValidForFormat:NSPropertyListXMLFormat_v1_0];
        if ( ! isValid) return nil;
        
        return [NSPropertyListSerialization dataWithPropertyList:input format:NSPropertyListXMLFormat_v1_0 options:kNilOptions error:nil];
    }]
            describe:[NSString stringWithFormat:@"deserialize %@property list", (mutable? @"mutable " : @"")]
            reverse:@"serialize property list"];
}


+ (OCATransformer *)deserializeJSONMutable:(BOOL)mutable {
    return [[OCATransformer fromClass:[NSData class] toClass:nil transform:^id(NSData *input) {
        if ( ! input) return nil;
        return [NSJSONSerialization JSONObjectWithData:input options:(mutable? NSJSONReadingMutableContainers : kNilOptions) error:nil];
    } reverse:^NSData *(id input) {
        if ( ! input) return nil;
        
        BOOL isValid = [NSJSONSerialization isValidJSONObject:input];
        if ( ! isValid) return nil;
        
        return [NSJSONSerialization dataWithJSONObject:input options:kNilOptions error:nil];
    }]
            describe:[NSString stringWithFormat:@"deserialize %@JSON", (mutable? @"mutable " : @"")]
            reverse:@"serialize JSON"];
}






@end


