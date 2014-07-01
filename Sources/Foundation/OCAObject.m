//
//  OCAObject.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAObject.h"
@import ObjectiveC.runtime;





@implementation OCAObject





#pragma mark Class Checking


+ (Class)valueClassForClasses:(NSArray *)classes {
    if ([classes containsObject:[NSObject class]]) return [NSObject class];
    if ([classes containsObject:NSNull.null]) return nil;
    
    Class finalClass = classes.firstObject;
    while (finalClass) {
        BOOL isCommonToAll = YES;
        for (Class class in classes) {
            BOOL isSuperclass = [class isSubclassOfClass:finalClass];
            isCommonToAll &= isSuperclass;
            if ( ! isCommonToAll) break;
        }
        if (isCommonToAll) break;
        finalClass = finalClass.superclass;
    }
    return finalClass;
}


- (Class)valueClassForClasses:(NSArray *)classes {
    return [self.class valueClassForClasses:classes];
}


+ (BOOL)validateObject:(__autoreleasing id *)objectPtr ofClass:(Class)class {
    return [self validateObject:objectPtr ofClasses:(class? @[ class ] : nil)];
}


- (BOOL)validateObject:(__autoreleasing id *)objectPtr ofClass:(Class)class {
    return [self.class validateObject:objectPtr ofClass:class];
}


+ (BOOL)validateObject:(id *)objectPtr ofClasses:(NSArray *)classes {
    if ( ! classes.count) return YES;
    
    id object = *objectPtr;
    if ( ! object) return YES;
    
    if ([object isKindOfClass:[NSNull class]]) {
        *objectPtr = nil;
        return YES;
    }
    BOOL isClass = class_isMetaClass(object_getClass(object));
    if (isClass) {
        for (Class class in classes) {
            if ([object isSubclassOfClass:class]) return YES;
        }
    }
    else {
        for (Class class in classes) {
            if ([object isKindOfClass:class]) return YES;
        }
    }
    BOOL isKindOfAnyOfThoseClasses = NO;
    OCAAssert(isKindOfAnyOfThoseClasses, @"Expected one of [%@] classes, but got %@.", [classes componentsJoinedByString:@", "], [object class]) {}
    *objectPtr = nil;
    return NO;
}


- (BOOL)validateObject:(id *)objectPtr ofClasses:(NSArray *)classes {
    return [self.class validateObject:objectPtr ofClasses:classes];
}


+ (BOOL)isClass:(Class)class1 compatibleWithClass:(Class)class2 {
    if ( ! class1) return YES;
    if ( ! class2) return YES;
    return [class1 isSubclassOfClass:class2];
}


+ (BOOL)isClass:(Class)classToCheck compatibleWithClasses:(NSArray *)classes {
    if ( ! classToCheck) return YES;
    if ( ! classes.count) return YES;
    
    for (Class class in classes) {
        if ([classToCheck isSubclassOfClass:class]) return YES;
    }
    return NO;
}


- (BOOL)isClass:(Class)class1 compatibleWithClass:(Class)class2 {
    return [self.class isClass:class1 compatibleWithClass:class2];
}





#pragma mark Describing Objects


- (NSString *)descriptionName {
    return NSStringFromClass(self.class);
}


- (NSString *)description {
    return self.shortDescription;
    // OCAObject (0x0)
}


- (NSString *)shortDescription {
    return [NSString stringWithFormat:@"%@ (%p)", self.descriptionName, self];
}


- (NSString *)debugDescription {
    NSDictionary *descriptionValues = [self debugDescriptionValues];
    NSMutableArray *valueStrings = [[NSMutableArray alloc] init];
    [valueStrings addObject:@""];
    [descriptionValues enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSObject *value, BOOL *stop) {
        [valueStrings addObject:[NSString stringWithFormat:@"%@ = %@", key, value]];
    }];
    
    
    return [NSString stringWithFormat:@"<%@ %p%@>",
            self.class, self, [valueStrings componentsJoinedByString:@"; "]];
}


- (NSString *)debugShortDescription {
    return [NSString stringWithFormat:@"<%@ %p>", self.class.description, self];
}


- (NSDictionary *)debugDescriptionValues {
    return @{};
}





@end


