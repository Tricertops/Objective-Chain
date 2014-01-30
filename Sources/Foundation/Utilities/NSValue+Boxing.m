//
//  NSValue+Boxing.m
//  Objective-Chain
//
//  Created by Martin Kiss on 3.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "NSValue+Boxing.h"





@implementation NSValue (Boxing)


//TODO: Something better than macros.




#define NSValueConditional(TYPE)                    if (strcmp(type, @encode(TYPE)) == 0)


+ (id)boxValue:(const void *)buffer objCType:(const char *)type {
#define NSValueConditionalyBoxNumber(TYPE)       NSValueConditional(TYPE) return @( * (TYPE *)buffer)
    
    NSValueConditional(void) return nil;
    
    NSValueConditionalyBoxNumber(char);
    NSValueConditionalyBoxNumber(short);
    NSValueConditionalyBoxNumber(int);
    NSValueConditionalyBoxNumber(long);
    NSValueConditionalyBoxNumber(long long);
    
    NSValueConditionalyBoxNumber(unsigned char);
    NSValueConditionalyBoxNumber(unsigned short);
    NSValueConditionalyBoxNumber(unsigned int);
    NSValueConditionalyBoxNumber(unsigned long);
    NSValueConditionalyBoxNumber(unsigned long long);
    
    NSValueConditionalyBoxNumber(float);
    NSValueConditionalyBoxNumber(double);
    
    NSValueConditionalyBoxNumber(_Bool);
    
    return [NSValue valueWithBytes:buffer objCType:type];
    
#undef NSValueConditionalyBoxNumber
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


+ (BOOL)objCTypeIsNumeric:(const char *)type {
    if ( ! type) return NO;
    
    NSValueConditional(char) return YES;
    NSValueConditional(short) return YES;
    NSValueConditional(int) return YES;
    NSValueConditional(long) return YES;
    NSValueConditional(long long) return YES;
    
    NSValueConditional(unsigned char) return YES;
    NSValueConditional(unsigned short) return YES;
    NSValueConditional(unsigned int) return YES;
    NSValueConditional(unsigned long) return YES;
    NSValueConditional(unsigned long long) return YES;
    
    NSValueConditional(float) return YES;
    NSValueConditional(double) return YES;
    
    NSValueConditional(_Bool) return YES;
    
    return NO;
}


#undef NSValueConditional




@end
