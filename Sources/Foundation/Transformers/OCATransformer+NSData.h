//
//  OCATransformer+NSData.h
//  Objective-Chain
//
//  Created by Martin Kiss on 10.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer+Base.h"





@interface OCATransformer (NSData)



#pragma mark -
#pragma mark Data
#pragma mark -

#pragma mark Creating Data

+ (OCATransformer *)dataFromFile;
+ (OCATransformer *)dataFromString; //! UTF-8
+ (OCATransformer *)subdataWithRange:(NSRange)range;


#pragma mark Keyed Archivation

+ (OCATransformer *)archiveBinary:(BOOL)binary;
+ (OCATransformer *)unarchive;


#pragma mark Property List Serialization

+ (OCATransformer *)serializePropertyListBinary:(BOOL)binary;
+ (OCATransformer *)deserializePropertyListMutable:(BOOL)isMutable;


#pragma mark JSON Serialization

+ (OCATransformer *)serializeJSONPretty:(BOOL)pretty;
+ (OCATransformer *)deserializeJSONMutable:(BOOL)isMutable;


#pragma mark Base64 Encoding

+ (OCATransformer *)decodeBase64Data;
+ (OCATransformer *)encodeBase64Data;


#pragma mark Hexadecimal String

+ (OCATransformer *)dataFromHex;
+ (OCATransformer *)hexFromData;



#pragma mark -
#pragma mark UUID
#pragma mark -

#pragma mark Creating UUID

+ (OCATransformer *)UUIDFromData;
+ (OCATransformer *)UUIDFromString;

#pragma mark Disposing UUID

+ (OCATransformer *)dataFromUUID;
+ (OCATransformer *)stringFromUUID;



@end


