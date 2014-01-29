//
//  OCAKeyPathAccessor.m
//  Objective-Chain
//
//  Created by Martin Kiss on 8.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAKeyPathAccessor.h"
#import "OCAStructureAccessor.h"




@interface OCAKeyPathAccessor ()

@end










@implementation OCAKeyPathAccessor





#pragma mark Creating Key-Path Accessor


- (instancetype)initWithObjectClass:(Class)objectClass keyPath:(NSString *)keyPath objCType:(const char *)objCType valueClass:(__unsafe_unretained Class)valueClass {
    self = [super init];
    if (self) {
        OCAAssert(keyPath.length > 0, @"Missing key-path.") return nil;
        
        self->_objectClass = objectClass;
        self->_keyPath = keyPath;
        self->_objCType = objCType;
        
        BOOL isObject = (objCType && strcmp(@encode(id), objCType) == 0);
        BOOL isNumeric = [NSValue objCTypeIsNumeric:objCType];
        if (isNumeric) {
            OCAAssert(valueClass == nil || valueClass == [NSNumber class], @"Provided wrongs wrapper class.");
            self->_valueClass = [NSNumber class];
            self->_isWrapping = YES;
        }
        else if ( ! isObject) {
            OCAAssert(valueClass == nil || valueClass == [NSValue class], @"Provided wrongs wrapper class.");
            self->_valueClass = [NSValue class];
            self->_isWrapping = YES;
        }
        else {
            self->_valueClass = valueClass;
            self->_isWrapping = NO;
        }
    }
    return self;
}


- (instancetype)initWithObjectClass:(Class)objectClass keyPath:(NSString *)keyPath structureAccessor:(OCAStructureAccessor *)structureAccessor {
    self = [self initWithObjectClass:objectClass keyPath:keyPath objCType:[structureAccessor memberType] valueClass:[structureAccessor valueClass]];
    if (self) {
        OCAAssert(structureAccessor != nil, @"") return nil;
        
        self->_structureAccessor = structureAccessor;
    }
    return self;
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


