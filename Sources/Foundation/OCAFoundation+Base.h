//
//  OCAFoundation+Base.h
//  Objective-Chain
//
//  Created by Martin Kiss on 10.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAObject.h"
#import "OCATransformer.h"



//TODO: Register default transformers on class basis?






@interface OCAFoundation : OCAObject





#pragma mark Transformers

+ (OCATransformer *)test:(NSPredicate *)predicate;
+ (OCATransformer *)negate;
+ (OCATransformer *)passes:(NSPredicate *)predicate or:(id)replacement;
+ (OCATransformer *)evaluate:(NSExpression *)expression;
+ (OCATransformer *)map:(NSDictionary *)dictionary;





@end





extern NSUInteger OCANormalizeIndex(NSInteger index, NSUInteger length);
extern NSRange OCANormalizeRange(NSRange range, NSUInteger length);


