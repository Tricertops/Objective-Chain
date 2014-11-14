//
//  OCAKeyPathAccessor.m
//  Objective-Chain
//
//  Created by Martin Kiss on 8.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAKeyPathAccessor.h"
#import "OCAStructureAccessor.h"
#import <libkern/OSAtomic.h>
#import <objc/runtime.h>





@interface OCAKeyPathAccessor ()

@end










@implementation OCAKeyPathAccessor





#pragma mark Creating Key-Path Accessor


+ (instancetype)accessorForObjectClass:(Class)objectClass keyPath:(NSString *)keyPath objCType:(const char *)objCType valueClass:(Class)valueClass {
    OCAAssert(keyPath.length > 0, @"Missing key-path.") return nil;
    return [self accessorForObjectClass:objectClass keyPath:keyPath objCType:objCType valueClass:valueClass structureAccessor:nil];
}


+ (instancetype)accessorForObjectClass:(Class)objectClass keyPath:(NSString *)keyPath structureAccessor:(OCAStructureAccessor *)structureAccessor {
    OCAAssert(structureAccessor != nil, @"") return nil;
    return [self accessorForObjectClass:objectClass keyPath:keyPath objCType:structureAccessor.memberType valueClass:structureAccessor.valueClass structureAccessor:structureAccessor];
}


+ (instancetype)accessorForObjectClass:(Class)objectClass keyPath:(NSString *)keyPath objCType:(const char *)objCType valueClass:(Class)valueClass structureAccessor:(OCAStructureAccessor *)structAccess {
    BOOL isObject = (objCType && strcmp(@encode(id), objCType) == 0);
    BOOL isNumeric = [NSValue objCTypeIsNumeric:objCType];
    BOOL isWrapping = NO;
    if (isNumeric) {
        OCAAssert(valueClass == nil || valueClass == [NSNumber class], @"Provided wrongs wrapper class.");
        valueClass = [NSNumber class];
        isWrapping = YES;
    }
    else if ( ! isObject) {
        OCAAssert(valueClass == nil || valueClass == [NSValue class], @"Provided wrongs wrapper class.");
        valueClass = [NSValue class];
        isWrapping = YES;
    }
    else {
        valueClass = (valueClass == [NSObject class]? nil : valueClass); // NSObject is useless, better use nil.
    }
    
    // We need a key that is unique for given combination of arguments.
    // This is much faster than +stringWithFormat: and since this piece of code is called a pretty often, it makes difference.
    char cacheKeyRaw[200];
    snprintf(cacheKeyRaw, 200, "%s|%s|%s|%s|%s|%s",
             class_getName(objectClass ?: [NSObject class]),
             keyPath.UTF8String ?: "",
             class_getName(valueClass ?: [NSObject class]),
             structAccess.structType ?: "",
             structAccess.memberPath.UTF8String ?: "",
             structAccess.memberType ?: "");
    id cacheKey = @(cacheKeyRaw);
    
    static volatile OSSpinLock lock = OS_SPINLOCK_INIT;
    OSSpinLockLock(&lock);
    
    OCAKeyPathAccessor *accessor = [[self.class sharedKeyPathAccessors] objectForKey:cacheKey];
    if ( ! accessor) {
        accessor = [[self alloc] initWithObjectClass:objectClass keyPath:keyPath objCType:objCType valueClass:valueClass isWrapping:isWrapping structureAccessor:structAccess];
        [[self.class sharedKeyPathAccessors] setObject:accessor forKey:cacheKey];
    }
    
    OSSpinLockUnlock(&lock);
    
    return accessor;
}


- (instancetype)initWithObjectClass:(Class)objectClass keyPath:(NSString *)keyPath objCType:(const char *)objCType valueClass:(Class)valueClass isWrapping:(BOOL)isWrapping structureAccessor:(OCAStructureAccessor *)structAccess {
    self = [super init];
    if (self) {
        self->_objectClass = objectClass;
        self->_keyPath = keyPath;
        self->_objCType = objCType;
        self->_valueClass = valueClass;
        self->_isWrapping = isWrapping;
        self->_structureAccessor = structAccess;
    }
    return self;
}


+ (NSMutableDictionary *)sharedKeyPathAccessors {
    static NSMutableDictionary *sharedAccessors = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAccessors = [NSMutableDictionary new];
    });
    return sharedAccessors;
}





#pragma mark Using Accessor


- (id)accessObject:(id)object {
    if ( ! object) return nil;
    
    id value = [object valueForKeyPath:self.keyPath];
    
    if (self.structureAccessor) {
        value = [self.structureAccessor memberFromStructure:value];
    }
    return value;
}


- (id)modifyObject:(id)object withValue:(id)value {
    if ( ! object) return nil;
    
    if (self.structureAccessor) {
        NSValue *structure = [object valueForKeyPath:self.keyPath];
        NSValue *modifiedStructure = [self.structureAccessor setMember:value toStructure:structure];
        [object setValue:modifiedStructure forKeyPath:self.keyPath];
    }
    else {
        if (value == nil && self.isWrapping) {
            if ([self.valueClass isSubclassOfClass:[NSNumber class]]) {
                // Properties that are BOOL or NSUInteger must not be set with nil, but rather a zero.
                value = @0;
            }
            else {
                OCAAssert(NO, @"Cannot automatically replace nil for this type '%s', yet.", self.objCType);
                return object;
            }
        }
        [object setValue:value forKeyPath:self.keyPath];
    }
    
    return object;
}





#pragma mark Comparing Key-Path Accessor


- (NSUInteger)hash {
    return (self.objectClass.hash
            ^ self.keyPath.hash
            ^ self.valueClass.hash
            ^ self.structureAccessor.hash);
}


- (BOOL)isEqual:(OCAKeyPathAccessor *)other {
    if (other == self) return YES;
    if (other.class != self.class) return NO;
    
    return (OCAEqual(self.objectClass, other.objectClass)
            && OCAEqualString(self.keyPath, other.keyPath)
            && OCAEqual(self.valueClass, other.valueClass)
            && OCAEqual(self.structureAccessor, other.structureAccessor));
}


- (NSSortDescriptor *)sortAscending:(BOOL)ascending {
    SEL stringCompare = @selector(localizedCaseInsensitiveCompare:);
    SEL objectCompare = @selector(compare:);
    SEL compare = ([self.class instanceMethodForSelector:stringCompare] ? stringCompare : objectCompare);
    return [NSSortDescriptor sortDescriptorWithKey:self.keyPath ascending:ascending selector:compare];
}




#pragma mark Describing Key-Path Accessors


- (NSString *)descriptionName {
    return [NSString stringWithFormat:@"%@.%@", self.objectClass, self.keyPath];
}


- (NSString *)shortDescription {
    return self.descriptionName;
}


- (NSDictionary *)debugDescriptionValues {
    return @{
             @"objectClass": self.objectClass,
             @"keyPath": self.keyPath,
             @"valueClass": self.valueClass,
             };
}





@end


