//
//  NSValue+Boxing.h
//  Objective-Chain
//
//  Created by Martin Kiss on 3.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>



#define OCABox(VALUE) \
(id)({ \
    typeof(VALUE) v = (VALUE); \
    [NSValue boxValue:&v objCType:@encode(typeof(v))]; \
}) \



#define OCAUnbox(VALUE, TYPE, REPLACEMENT) \
(TYPE)({ \
    TYPE v; \
    BOOL s = [(VALUE) unboxValue:&v objCType:@encode(TYPE)]; \
    s? v : (REPLACEMENT); \
}) \



@interface NSValue (Boxing)


+ (id)boxValue:(const void *)buffer objCType:(const char *)type;
- (BOOL)unboxValue:(void *)buffer objCType:(const char *)type;

+ (BOOL)objCTypeIsNumeric:(const char *)type;


@end
