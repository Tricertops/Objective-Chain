//
//  OCAKeyPathAccessor.h
//  Objective-Chain
//
//  Created by Martin Kiss on 8.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAAccessor.h"
#import "OCAStructureAccessor.h"





@interface OCAKeyPathAccessor : OCAAccessor



#pragma mark Creating Key-Path Accessor

#define OCAKeyPath(CLASS, KEYPATH, TYPE)            OCAKeyPathAccessorCreate(CLASS, KEYPATH, TYPE)
#define OCAKeyPathStruct(CLASS, KEYPATH, MEMBER)    OCAKeyPathAccessorCreateWithStructure(CLASS, KEYPATH, MEMBER)
#define OCAKeyPathUnsafe(KEYPATH)                   OCAKeyPathAccessorCreateUnsafe(KEYPATH)

- (instancetype)initWithObjectClass:(Class)objectClass
                            keyPath:(NSString *)keyPath
                         valueClass:(Class)valueClass;

- (instancetype)initWithObjectClass:(Class)objectClass
                            keyPath:(NSString *)keyPath
                  structureAccessor:(OCAStructureAccessor *)structureAccessor;


#pragma mark Attributes of Key-Path Accessor

@property (atomic, readonly, strong) Class objectClass;
@property (atomic, readonly, copy) NSString *keyPath;
@property (atomic, readonly, strong) Class valueClass;

@property (atomic, readonly, strong) OCAStructureAccessor *structureAccessor;


#pragma mark Comparing Key-Path Accessor

- (NSUInteger)hash;
- (BOOL)isEqual:(OCAKeyPathAccessor *)other;



@end





#define OCAKeyPathAccessorCreate(CLASS, KEYPATH, TYPE) \
(OCAKeyPathAccessor *)({ \
    const char *type = @encode(TYPE *); \
    BOOL isObject = (strcmp(@encode(id), type) == 0); \
    BOOL isNumeric = [NSValue objCTypeIsNumeric:(type+1)]; \
    [[OCAKeyPathAccessor alloc] initWithObjectClass:[CLASS class] \
                                            keyPath:OCAKP(CLASS, KEYPATH) \
                                         valueClass:(isObject? NSClassFromString(@#TYPE) \
                                                     : (isNumeric? [NSNumber class] : [NSValue class]))]; \
}) \





#define OCAKeyPathAccessorCreateFromObject(OBJECT, KEYPATH, TYPE) \
(OCAKeyPathAccessor *)({ \
    const char *type = @encode(TYPE *); \
    BOOL isObject = (strcmp(@encode(id), type) == 0); \
    BOOL isNumeric = [NSValue objCTypeIsNumeric:(type+1)]; \
    [[OCAKeyPathAccessor alloc] initWithObjectClass:[OBJECT class] \
                                            keyPath:OCAKPObject(OBJECT, KEYPATH) \
                                         valueClass:(isObject? NSClassFromString(@#TYPE) \
                                                     : (isNumeric? [NSNumber class] : [NSValue class]))]; \
}) \





#define OCAKeyPathAccessorCreateWithStructure(CLASS, KEYPATH, MEMBER) \
(OCAKeyPathAccessor *)({ \
    CLASS *o; \
    (void)o.KEYPATH.MEMBER; \
    [[OCAKeyPathAccessor alloc] initWithObjectClass:[CLASS class] \
                                            keyPath:OCAKP(CLASS, KEYPATH) \
                                  structureAccessor:OCAStructureAccessorCreate(o.KEYPATH, MEMBER)]; \
}) \





#define OCAKeyPathAccessorCreateWithStructureFromObject(OBJECT, KEYPATH, MEMBER) \
(OCAKeyPathAccessor *)({ \
    typeof(OBJECT) o; \
    (void)o.KEYPATH.MEMBER; \
    [[OCAKeyPathAccessor alloc] initWithObjectClass:[(OBJECT) class] \
                                            keyPath:OCAKPObject((OBJECT), KEYPATH) \
                                  structureAccessor:OCAStructureAccessorCreate(o.KEYPATH, MEMBER)]; \
}) \




#define OCAKeyPathAccessorCreateUnsafe(KEYPATH) \
(OCAKeyPathAccessor *)({ \
    [[OCAKeyPathAccessor alloc] initWithObjectClass:nil keyPath:KEYPATH valueClass:nil]; \
}) \





