//
//  OCAFoundation+Base.h
//  Objective-Chain
//
//  Created by Martin Kiss on 10.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAObject.h"
#import "OCATransformer.h"





@interface OCAFoundation : OCAObject

@end





extern NSUInteger OCANormalizeIndex(NSInteger index, NSUInteger length);
extern NSRange OCANormalizeRange(NSRange range, NSUInteger length);





#define CLAMP(MIN, VALUE, MAX) \
(typeof(VALUE))({ \
    typeof(VALUE) __min = (MIN); \
    typeof(VALUE) __value = (VALUE); \
    typeof(VALUE) __max = (MAX); \
    (__value > __max ? __max : (__value < __min ? __min : __value)); \
})


//TODO: Register default transformers on class basis?
