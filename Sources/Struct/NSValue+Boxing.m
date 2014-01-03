//
//  NSValue+Boxing.m
//  Objective-Chain
//
//  Created by Martin Kiss on 3.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "NSValue+Boxing.h"





@implementation NSValue (Boxing)




#define NSValueConditional(TYPE)                    if (strcmp(type, @encode(TYPE)) == 0)


+ (id)boxValue:(const void *)buffer objCType:(const char *)type {
#define NSValueConditionalyReturnNumber(TYPE)       NSValueConditional(TYPE) return @( * (TYPE *)buffer)
    
    NSValueConditional(void) return nil;
    
    NSValueConditionalyReturnNumber(char);
    NSValueConditionalyReturnNumber(short);
    NSValueConditionalyReturnNumber(int);
    NSValueConditionalyReturnNumber(long);
    NSValueConditionalyReturnNumber(long long);
    
    NSValueConditionalyReturnNumber(unsigned char);
    NSValueConditionalyReturnNumber(unsigned short);
    NSValueConditionalyReturnNumber(unsigned int);
    NSValueConditionalyReturnNumber(unsigned long);
    NSValueConditionalyReturnNumber(unsigned long long);
    
    NSValueConditionalyReturnNumber(float);
    NSValueConditionalyReturnNumber(double);
    
    NSValueConditionalyReturnNumber(_Bool);
    
    return [NSValue valueWithBytes:buffer objCType:type];
    
#undef NSValueConditionalyReturnNumber
}


- (BOOL)unboxValue:(void *)buffer objCType:(const char *)type {
#define NSValueConditionalyUnboxNumber(TYPE, METHOD) \
NSValueConditional(TYPE) { \
    if ([self isKindOfClass:NSNumber.class]) { \
        * (TYPE *)buffer = [(NSNumber *)self METHOD]; \
        return YES; \
    } \
    else return NO; \
} \

    NSValueConditional(void) {
        return NO;
    }
    
    NSValueConditionalyUnboxNumber(char, charValue);
    NSValueConditionalyUnboxNumber(short, shortValue);
    NSValueConditionalyUnboxNumber(int, intValue);
    NSValueConditionalyUnboxNumber(long, longValue);
    NSValueConditionalyUnboxNumber(long long, longLongValue);
    
    NSValueConditionalyUnboxNumber(unsigned char, unsignedCharValue);
    NSValueConditionalyUnboxNumber(unsigned short, unsignedShortValue);
    NSValueConditionalyUnboxNumber(unsigned int, unsignedIntValue);
    NSValueConditionalyUnboxNumber(unsigned long, unsignedLongValue);
    NSValueConditionalyUnboxNumber(unsigned long long, unsignedLongLongValue);
    
    NSValueConditionalyUnboxNumber(float, floatValue);
    NSValueConditionalyUnboxNumber(double, doubleValue);
    
    NSValueConditionalyUnboxNumber(_Bool, boolValue);
    
    if (strcmp(type, self.objCType) == 0) {
        [self getValue:buffer];
        return YES;
    }

    return NO;
    
#undef NSValueConditionalyUnboxNumber
}


#undef NSValueConditional




@end
