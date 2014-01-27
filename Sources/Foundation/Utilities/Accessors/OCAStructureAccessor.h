//
//  OCAStructureAccessor.h
//  Objective-Chain
//
//  Created by Martin Kiss on 3.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAAccessor.h"
#import "NSValue+Boxing.h"





@interface OCAStructureAccessor : OCAAccessor



#pragma mark Creating Structure Accessor

#define OCAStruct(STRUCT, MEMBER)       OCAStructureAccessorCreate(STRUCT, MEMBER)

- (instancetype)initWithStructType:(const char *)structType
                        memberPath:(NSString *)memberPath
                        memberType:(const char *)memberType
                          getBlock:(NSValue *(^)(NSValue *structValue))getBlock
                          setBlock:(NSValue *(^)(NSValue *structValue, NSValue *memberValue))setBlock;


#pragma mark Attributes of Structure Accessor

@property (atomic, readonly, assign) const char *structType;
@property (atomic, readonly, copy) NSString *memberPath;
@property (atomic, readonly, assign) const char *memberType;

@property (atomic, readonly, assign) BOOL isNumeric;


#pragma mark Describing Structure Accessor

@property (atomic, readwrite, assign) NSString *structureDescription;
@property (atomic, readwrite, assign) NSString *memberDescription;
- (instancetype)describeStructure:(NSString *)structure member:(NSString *)member;


#pragma mark Using Structure Accessor

- (NSValue *)memberFromStructure:(NSValue *)structValue;
- (NSValue *)setMember:(NSValue *)memberValue toStructure:(NSValue *)structValue;


#pragma mark Comparing Structure Accessor

- (NSUInteger)hash;
- (BOOL)isEqual:(OCAStructureAccessor *)other;



@end





#define OCAStructureAccessorCreate(STRUCT, MEMBER) \
(OCAStructureAccessor *)({ \
    typeof(STRUCT) s; \
    const char *structType = @encode(typeof(s)); \
    const char *memberType = @encode(typeof(s.MEMBER)); \
    [[[OCAStructureAccessor alloc] initWithStructType:structType memberPath:@#MEMBER memberType:memberType getBlock:^NSValue *(NSValue *structValue) { \
        typeof(s) structure; \
        BOOL unboxed = [structValue unboxValue:&structure objCType:structType]; \
        if ( ! unboxed) return nil; \
        typeof(s.MEMBER) member = structure.MEMBER; \
        return [NSValue boxValue:&member objCType:memberType]; \
    } setBlock:^NSValue *(NSValue *structValue, NSValue *memberValue) { \
        typeof(s) structure; \
        BOOL structUnboxed = [structValue unboxValue:&structure objCType:structType]; \
        if ( ! structUnboxed) return nil; \
        typeof(s.MEMBER) member; \
        BOOL memberUnboxed = [memberValue unboxValue:&member objCType:memberType]; \
        if ( ! memberUnboxed) return nil; \
        structure.MEMBER = member; \
        return [NSValue valueWithBytes:&structure objCType:structType]; \
    }] describeStructure:@#STRUCT member:@#MEMBER]; \
}) \


inline NSValue *_OCAStructureAccessorGetBlockExample(NSValue *structValue) {
    NSRange s;
    const char *structType = @encode(typeof(s));
    const char *memberType = @encode(typeof(s.location));
    
    
    typeof(s) structure;
    BOOL unboxed = [structValue unboxValue:&structure objCType:structType];
    if ( ! unboxed) return nil;
    
    typeof(s.location) member = structure.location;
    return [NSValue boxValue:&member objCType:memberType];
}


inline NSValue *_OCAStructureAccessorSetBlockExample(NSValue *structValue, NSValue *memberValue) {
    NSRange s;
    const char *structType = @encode(typeof(s));
    const char *memberType = @encode(typeof(s.location));
    
    
    typeof(s) structure;
    BOOL structUnboxed = [structValue unboxValue:&structure objCType:structType];
    if ( ! structUnboxed) return nil;
    
    typeof(s.location) member;
    BOOL memberUnboxed = [memberValue unboxValue:&member objCType:memberType];
    if ( ! memberUnboxed) return nil;
    structure.location = member;
    return [NSValue valueWithBytes:&structure objCType:structType];
}


