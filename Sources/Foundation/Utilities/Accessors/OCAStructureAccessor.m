//
//  OCAStructureAccessor.m
//  Objective-Chain
//
//  Created by Martin Kiss on 3.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAStructureAccessor.h"





@interface OCAStructureAccessor ()


@property (atomic, readonly, copy) NSValue *(^getBlock)(NSValue *);
@property (atomic, readonly, copy) NSValue *(^setBlock)(NSValue *, NSValue *);


@end










@implementation OCAStructureAccessor





#pragma mark Creating Struct Member Accessor


- (instancetype)initWithStructType:(const char *)structType
                        memberPath:(NSString *)memberPath
                        memberType:(const char *)memberType
                          getBlock:(NSValue *(^)(NSValue *structValue))getBlock
                          setBlock:(NSValue *(^)(NSValue *structValue, NSValue *memberValue))setBlock {
    self = [super init];
    if (self) {
        OCAAssert( ! [NSValue objCTypeIsNumeric:structType], @"This is not a struct! Don't play with types or bad things will happen!") return nil;
        OCAAssert(memberPath.length > 0, @"Missing member path.") return nil;;
        OCAAssert(getBlock != nil, @"Missing get block.") return nil;
        OCAAssert(setBlock != nil, @"Missing set block.") return nil;
        
        self->_structType = structType;
        self->_memberPath = memberPath;
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


- (NSString *)descriptionName {
    return [NSString stringWithFormat:@"%@.%@", self.structureDescription, self.memberDescription];
}


- (NSString *)shortDescription {
    return self.descriptionName;
}


- (NSDictionary *)debugDescriptionValues {
    return @{
             @"structType": [NSString stringWithUTF8String:self.structType],
             @"memberType": [NSString stringWithUTF8String:self.memberType],
             };
}


- (instancetype)describeStructure:(NSString *)structure member:(NSString *)member {
    self.structureDescription = structure;
    self.memberDescription = member;
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





#pragma mark Superclass Overrides


- (Class)objectClass {
    return [NSValue class];
}


- (Class)valueClass {
    return (self.isNumeric? [NSNumber class] : [NSValue class]);
}


- (id)accessObject:(id)object {
    return [self memberFromStructure:object];
}


- (id)modifyObject:(id)object withValue:(id)value {
    return [self setMember:value toStructure:object];
}





#pragma mark Comparing Structure Accessor


- (NSUInteger)hash {
    NSString *structType = [NSString stringWithUTF8String:self.structType];
    NSString *memberType = [NSString stringWithUTF8String:self.memberType];
    return (structType.hash ^ self.memberPath.hash ^ memberType.hash);
}


- (BOOL)isEqual:(OCAStructureAccessor *)other {
    if (other == self) return YES;
    if (other.class != self.class) return NO;
    
    return (strcmp(self.structType, other.structType) == 0
            && OCAEqualString(self.memberPath, other.memberPath)
            && strcmp(self.memberType, other.memberType) == 0);
}





@end


