//
//  OCAObject.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>



#define OCAKPUnsafe(KEYPATH)            NSStringFromSelector(@selector(KEYPATH))
#define OCAKP(CLASS, KEYPATH)           OCAKPObject([CLASS new], KEYPATH)
#define OCAKPObject(OBJECT, KEYPATH)    ((NSString *)@(((void)(NO && ((void)OBJECT.KEYPATH, NO)), # KEYPATH)))

#define OCAWeakify(VARIABLE)            __weak typeof(VARIABLE) VARIABLE##_weak = VARIABLE
#define OCAStrongify(VARIABLE)          __strong typeof(VARIABLE##_weak) VARIABLE = VARIABLE##_weak

#define OCAEqual(A, B)                  OCAEqualCustom(A, isEqual:, B)
#define OCAEqualString(A, B)            OCAEqualCustom(A, isEqualToString:, B)
#define OCAEqualCustom(A, SELECTOR, B) \
(BOOL)({ \
    typeof(A) a = (A); \
    typeof(B) b = (B); \
    ((a == b) || (b && [a SELECTOR b])); \
}) \

#define OCA_iOS     TARGET_OS_IPHONE

#define CONVENIENCE





@interface OCAObject : NSObject



#pragma mark Class Checking

+ (Class)valueClassForClasses:(NSArray *)classes;
- (Class)valueClassForClasses:(NSArray *)classes;

+ (BOOL)validateObject:(id *)object ofClass:(Class)class;
- (BOOL)validateObject:(id *)object ofClass:(Class)class;

+ (BOOL)isClass:(Class)class1 compatibleWithClass:(Class)class2;
- (BOOL)isClass:(Class)class1 compatibleWithClass:(Class)class2;


#pragma mark Describing Objects

- (NSString *)descriptionName;
- (NSString *)description;
- (NSString *)shortDescription;
- (NSDictionary *)debugDescriptionValues;
- (NSString *)debugDescription;
- (NSString *)debugShortDescription;



@end





#define NSArrayFromVariadicArguments(FIRST) \
(NSMutableArray *)({ \
    va_list list; \
    va_start(list, FIRST); \
    NSMutableArray *objects = [[NSMutableArray alloc] init]; \
    id object = FIRST; \
    while (object) { \
        [objects addObject:object]; \
        object = va_arg(list, id); \
    } \
    va_end(list); \
    objects; \
})





#define NSStringFromFormat(format)\
(NSString *)({\
    va_list __vargs;\
    va_start(__vargs, format);\
    NSString *__string = [[NSString alloc] initWithFormat:format arguments:__vargs];\
    va_end(__vargs);\
    __string;\
})





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


