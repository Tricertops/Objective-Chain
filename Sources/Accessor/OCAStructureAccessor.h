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



- (instancetype)initWithStructType:(const char *)structType
                        memberType:(const char *)memberType
                          getBlock:(NSValue *(^)(NSValue *structValue))getBlock
                          setBlock:(NSValue *(^)(NSValue *structValue, NSValue *memberValue))setBlock;

@property (atomic, readonly, assign) const char *structType;
@property (atomic, readonly, assign) const char *memberType;

@property (atomic, readonly, assign) BOOL isNumeric;

@property (atomic, readwrite, assign) NSString *structureDescription;
@property (atomic, readwrite, assign) NSString *memberDescription;
- (instancetype)describeStructure:(NSString *)structure member:(NSString *)member;


- (NSValue *)memberFromStructure:(NSValue *)structValue;
- (NSValue *)setMember:(NSValue *)memberValue toStructure:(NSValue *)structValue;



@end





#define OCAStruct(STRUCT, MEMBER) \
\
(OCAStructureAccessor *)({ \
    STRUCT s; \
    const char *structType = @encode(STRUCT); \
    const char *memberType = @encode(typeof(s.MEMBER)); \
    [[[OCAStructureAccessor alloc] initWithStructType:structType memberType:memberType getBlock:^NSValue *(NSValue *structValue) { \
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


