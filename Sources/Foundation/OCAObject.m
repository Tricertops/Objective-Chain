//
//  OCAObject.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAObject.h"





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
    if ( ! class) return YES;
    
    id object = *objectPtr;
    if ( ! object) return YES;
    
    if ([object isKindOfClass:[NSNull class]]) {
        *objectPtr = nil;
        return YES;
    }
    
    OCAAssert([object isKindOfClass:class], @"Expected %@ class, but got %@.", class, [object class]) {
        *objectPtr = nil;
        return NO;
    }
    
    return YES;
}


- (BOOL)validateObject:(__autoreleasing id *)objectPtr ofClass:(Class)class {
    return [self.class validateObject:objectPtr ofClass:class];
}


+ (BOOL)isClass:(Class)class1 compatibleWithClass:(Class)class2 {
    if ( ! class1) return YES;
    if ( ! class2) return YES;
    return [class1 isSubclassOfClass:class2];
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


