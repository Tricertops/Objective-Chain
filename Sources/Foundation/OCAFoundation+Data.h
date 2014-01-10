//
//  OCAFoundation+Data.h
//  Objective-Chain
//
//  Created by Martin Kiss on 10.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAFoundation+Base.h"





@interface OCAFoundation (Data)



#pragma mark NSData

/// Materializing Data
+ (OCATransformer *)dataFromFile;
+ (OCATransformer *)dataFromString;
+ (OCATransformer *)archiveBinary:(BOOL)binary;
+ (OCATransformer *)serializePropertyListBinary:(BOOL)binary;
+ (OCATransformer *)serializeJSONPretty:(BOOL)pretty;

/// Altering Data
+ (OCATransformer *)decodeBase64Data;
+ (OCATransformer *)encodeBase64Data;
+ (OCATransformer *)subdataWithRange:(NSRange)range;

/// Dematerializing Data
+ (OCATransformer *)unarchive;
+ (OCATransformer *)deserializePropertyListMutable:(BOOL)mutable;
+ (OCATransformer *)deserializeJSONMutable:(BOOL)mutable;



@end


