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
#define OCAKPObject(OBJECT, KEYPATH)    \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-repeated-use-of-weak\"") \
((NSString *)@(((void)(NO && ((void)OBJECT.KEYPATH, NO)), # KEYPATH))) \
_Pragma("clang diagnostic pop") \

#define OCAWeakify(VARIABLE)            __weak typeof(VARIABLE) VARIABLE##_weak = VARIABLE
#define OCAStrongify(VARIABLE)          __strong typeof(VARIABLE##_weak) VARIABLE = VARIABLE##_weak

#define OCAKeyPathsAffecting(AFFECTED, KEYPATHS...)\
+ (NSSet *)keyPathsForValuesAffecting##AFFECTED { return [NSSet setWithObjects: KEYPATHS, nil]; }

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

#define OCAT(TYPE)   @(@encode(TYPE))
#define OCATypes(...)   ( [@[ __VA_ARGS__ ] componentsJoinedByString:@""] )





@interface OCAObject : NSObject



#pragma mark Class Checking

+ (Class)valueClassForClasses:(NSArray *)classes;
- (Class)valueClassForClasses:(NSArray *)classes;

//! These methods take reference to the variable, because they may modify the value to make it valid. So far only one modification is made: NSNull is replaced with nil (and YES is returned).
+ (BOOL)validateObject:(id *)object ofClass:(Class)theClass;
- (BOOL)validateObject:(id *)object ofClass:(Class)theClass;
+ (BOOL)validateObject:(id *)object ofClasses:(NSArray *)classes;
- (BOOL)validateObject:(id *)object ofClasses:(NSArray *)classes;

+ (BOOL)isClass:(Class)class1 compatibleWithClass:(Class)class2;
+ (BOOL)isClass:(Class)classToCheck compatibleWithClasses:(NSArray *)classes;
- (BOOL)isClass:(Class)class1 compatibleWithClass:(Class)class2;


#pragma mark Describing Objects

- (NSString *)descriptionName;
- (NSString *)description;
- (NSString *)shortDescription;
- (NSDictionary *)debugDescriptionValues;
- (NSString *)debugDescription;
- (NSString *)debugShortDescription;



@end









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


