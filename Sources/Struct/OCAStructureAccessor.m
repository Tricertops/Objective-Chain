//
//  OCAStructureAccessor.m
//  Objective-Chain
//
//  Created by Martin Kiss on 3.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAStructureAccessor.h"





@interface OCAStructureAccessor ()


@property (OCA_atomic, readonly, copy) NSValue *(^getBlock)(NSValue *);
@property (OCA_atomic, readonly, copy) NSValue *(^setBlock)(NSValue *, NSValue *);


@end










@implementation OCAStructureAccessor





#pragma mark Creating Struct Member Accessor


- (instancetype)initWithStructType:(const char *)structType
                        memberType:(const char *)memberType
                          getBlock:(NSValue *(^)(NSValue *structValue))getBlock
                          setBlock:(NSValue *(^)(NSValue *structValue, NSValue *memberValue))setBlock {
    self = [super init];
    if (self) {
        OCAAssert( ! [NSValue objCTypeIsNumeric:structType], @"This is not a struct! Don't play with types or bad things will happen!") return nil;
        OCAAssert(getBlock != nil, @"Missing get block.");
        OCAAssert(setBlock != nil, @"Missing set block.");
        
        self->_structType = structType;
        self->_memberType = memberType;
        
        self->_isNumeric = [NSValue objCTypeIsNumeric:memberType];
        
        self->_getBlock = getBlock;
        self->_setBlock = setBlock;
        
        [self describeStructure:[NSString stringWithUTF8String:structType]
                         member:[NSString stringWithUTF8String:memberType]];
    }
    return self;
}





#pragma mark Describing Struct Member Accessors


- (NSString *)description {
    return [NSString stringWithFormat:@"%@.%@", self.structureDescription, self.memberDescription];
}


- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@ %p; structType = %s; memberType = %s; %@>", self.class, self, self.structType, self.memberType, self.description];
}


- (instancetype)describeStructure:(NSString *)structure member:(NSString *)member {
    self->_structureDescription = structure;
    self->_memberDescription = member;
    return self;
}





#pragma mark Using Struct Member Accessor


- (NSValue *)memberFromStructure:(NSValue *)structValue {
    if ( ! structValue) return nil;
    OCAAssert(strcmp(structValue.objCType, self.structType) == 0, @"Type mismatch for struct.") return nil;
    
    return self.getBlock(structValue);
}


- (NSValue *)setMember:(NSValue *)memberValue toStructure:(NSValue *)structValue {
    if ( ! structValue) return nil;
    OCAAssert(strcmp(structValue.objCType, self.structType) == 0, @"Type mismatch for struct.") return nil;
    
    if (memberValue) {
        if ([memberValue isKindOfClass:[NSNumber class]]) {
            OCAAssert(self.isNumeric, @"Numbers accepted only for numeric members.") return nil;
        }
        else {
            OCAAssert( ! self.isNumeric, @"Non-Numbers accepted only for sub-struct members.") return nil;
            OCAAssert(strcmp(memberValue.objCType, self.memberType) == 0, @"Type mismatch for struct member") return nil;
        }
    }
    // What can pass here: nil, NSNumber (only if the member is numeric), NSValue (only if member is non-numeric)
    return self.setBlock(structValue, memberValue);
}





@end


