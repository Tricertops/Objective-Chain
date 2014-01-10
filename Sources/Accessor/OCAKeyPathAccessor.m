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


- (instancetype)initWithObjectClass:(Class)objectClass keyPath:(NSString *)keyPath valueClass:(Class)valueClass {
    self = [super init];
    if (self) {
        OCAAssert(keyPath.length > 0, @"Missing key-path.") return nil;
        
        self->_objectClass = objectClass;
        self->_keyPath = keyPath;
        self->_valueClass = valueClass;
    }
    return self;
}


- (instancetype)initWithObjectClass:(Class)objectClass keyPath:(NSString *)keyPath structureAccessor:(OCAStructureAccessor *)structureAccessor {
    self = [self initWithObjectClass:objectClass keyPath:keyPath valueClass:[structureAccessor valueClass]];
    if (self) {
        OCAAssert(keyPath.length > 0, @"Missing key-path.") return nil;
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


