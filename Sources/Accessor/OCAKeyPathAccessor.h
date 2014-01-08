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

- (instancetype)initWithObjectClass:(Class)objectClass
                            keyPath:(NSString *)keyPath
                         valueClass:(Class)valueClass;

- (instancetype)initWithObjectClass:(Class)objectClass
                            keyPath:(NSString *)keyPath
                  structureAccessor:(OCAStructureAccessor *)structureAccessor;


#pragma mark Attributes of Key-Path Accessor

@property (atomic, readonly, copy) NSString *keyPath;
@property (atomic, readonly, strong) OCAStructureAccessor *structureAccessor;



@end





#define OCAKeyPath(CLASS, KEYPATH, TYPE) \
(OCAKeyPathAccessor *)({ \
    const char *type = @encode(TYPE *); \
    BOOL isObject = (strcmp(@encode(id), type) == 0); \
    BOOL isNumeric = [NSValue objCTypeIsNumeric:(type+1)]; \
    [[OCAKeyPathAccessor alloc] initWithObjectClass:[CLASS class] \
                                            keyPath:OCAKP(CLASS, KEYPATH) \
                                         valueClass:(isObject? NSClassFromString(@#TYPE) \
                                                     : (isNumeric? [NSNumber class] : [NSValue class]))]; \
}) \




#define OCAKeyPathStruct(CLASS, KEYPATH, MEMBER) \
(OCAKeyPathAccessor *)({ \
    CLASS *o; \
    (void)o.KEYPATH.MEMBER; \
    [[OCAKeyPathAccessor alloc] initWithObjectClass:[CLASS class] \
                                            keyPath:OCAKP(CLASS, KEYPATH) \
                                  structureAccessor:OCAStruct(o.KEYPATH, MEMBER)]; \
}) \




#define OCAKeyPathUnsafe(KEYPATH) \
(OCAKeyPathAccessor *)({ \
    [[OCAKeyPathAccessor alloc] initWithObjectClass:nil keyPath:KEYPATH valueClass:nil]; \
}) \





