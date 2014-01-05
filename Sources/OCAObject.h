//
//  OCAObject.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>


#define OCA_atomic  atomic


#define OCALazyGetter(TYPE, PROPERTY) \
@synthesize PROPERTY = _##PROPERTY; \
- (TYPE)PROPERTY { \
    if ( ! self->_##PROPERTY) { \
        self->_##PROPERTY = [self oca_lazyGetter_##PROPERTY]; \
    } \
    return self->_##PROPERTY; \
} \
- (TYPE)oca_lazyGetter_##PROPERTY \



#if !defined(NS_BLOCK_ASSERTIONS)

    #define OCAAssert(CONDITION, MESSAGE, ...) \
        if ( ! (CONDITION) && (( [[NSAssertionHandler currentHandler] \
                                   handleFailureInFunction: [NSString stringWithUTF8String:__PRETTY_FUNCTION__] \
                                   file: [NSString stringWithUTF8String:__FILE__] \
                                   lineNumber: __LINE__ \
                                   description: (MESSAGE), ##__VA_ARGS__], YES)) ) // Will NOT execute appended code, if exception is thrown.

#else

    #define OCAAssert(CONDITION, MESSAGE, ...)\
        if ( ! (CONDITION) && (( NSLog(@"*** Assertion failure in %s, %s:%d, Condition not satisfied: %s, reason: '" MESSAGE "'", __PRETTY_FUNCTION__, __FILE__, __LINE__, #CONDITION, ##__VA_ARGS__), YES)) ) // Will execute appended code.

#endif


#define OCAValidateClass(VARIABLE, CLASS) \
(BOOL)({ \
    Class class = (CLASS); \
    BOOL isKindOfClass = ( ! class || ! VARIABLE || [VARIABLE isKindOfClass:class]); \
    OCAAssert(isKindOfClass, @"Expected %@ class of '" # VARIABLE "', but got %@.", class, [VARIABLE class]) { \
        VARIABLE = nil; \
    } \
    isKindOfClass; \
}) \



#define OCAKeypathUnsafe(KEYPATH)           NSStringFromSelector(@selector(KEYPATH))
#define OCAKeypathObject(OBJECT, KEYPATH)   @(((void)(NO && ((void)OBJECT.KEYPATH, NO)), # KEYPATH))
#define OCAKeypath(CLASS, KEYPATH)          OCAKeypathObject([CLASS new], KEYPATH)


#define CLAMP(MIN, VALUE, MAX) \
({ \
    typeof(VALUE) __min = (MIN); \
    typeof(VALUE) __value = (VALUE); \
    typeof(VALUE) __max = (MAX); \
    (__value > __max ? __max : (__value < __min ? __min : __value)); \
})






@interface OCAObject : NSObject

@end
