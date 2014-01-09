//
//  OCAObject.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>



#define OCAKPUnsafe(KEYPATH)            NSStringFromSelector(@selector(KEYPATH))
#define OCAKP(CLASS, KEYPATH)           ((NSString *)@(((void)(NO && ((void)[[CLASS new] KEYPATH], NO)), # KEYPATH)))
#define OCAWeakify(VARIABLE)            __weak typeof(VARIABLE) VARIABLE##_weak = VARIABLE
#define OCAStrongify(VARIABLE)          __strong typeof(VARIABLE##_weak) VARIABLE = VARIABLE##_weak





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


