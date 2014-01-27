//
//  OCAProperty.h
//  Objective-Chain
//
//  Created by Martin Kiss on 9.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAProducer.h"
#import "OCAKeyPathAccessor.h"




typedef enum : NSUInteger {
    OCAPropertyOptionDefault = 0,
    
    OCAPropertyOptionIncludePreviousValue = 1 << 0,
//TODO: OCAPropertyOptionSkipInitialValue = 1 << 1,
//TODO: OCAPropertyOptionSendDuplicates = 1 << 2,
//TODO: OCAPropertyOptionObservePrior = 1 << 3,
    
} OCAPropertyOptions;






@interface OCAProperty : OCAProducer < OCAConsumer >



#pragma mark Creating Property Bridge

#define OCAProperty(OBJECT, KEYPATH, TYPE)                      OCAPropertyCreate(OBJECT, KEYPATH, TYPE, OCAPropertyOptionDefault)
#define OCAPropertyChange(OBJECT, KEYPATH, TYPE)                OCAPropertyCreate(OBJECT, KEYPATH, TYPE, OCAPropertyOptionIncludePreviousValue)
#define OCAPropertyStruct(OBJECT, KEYPATH, MEMBER)              OCAPropertyCreateWithStructure(OBJECT, KEYPATH, MEMBER, OCAPropertyOptionDefault)
#define OCAPropertyStructChange(OBJECT, KEYPATH, MEMBER)        OCAPropertyCreateWithStructure(OBJECT, KEYPATH, MEMBER, OCAPropertyOptionIncludePreviousValue)

- (instancetype)initWithObject:(NSObject *)object keyPathAccessor:(OCAKeyPathAccessor *)accessor options:(OCAPropertyOptions)options;


#pragma mark Attributes of Property Bridge

@property (atomic, readonly, weak) id object;
@property (atomic, readonly, copy) NSString *keyPath;
@property (atomic, readonly, copy) NSString *memberPath;
@property (atomic, readonly, strong) Class valueClass;
@property (atomic, readonly, assign) OCAPropertyOptions options;

@property (atomic, readonly, strong) OCAKeyPathAccessor *accessor;


#pragma mark Using Property

@property (atomic, readwrite, weak) id value;

//TODO: -sendLatest
//TODO: -sendChanges

#pragma mark Binding Properties

- (void)bindWith:(OCAProperty *)property CONVENIENCE;
- (void)bindTransformed:(NSValueTransformer *)transformer with:(OCAProperty *)property CONVENIENCE;



@end





#define OCAPropertyCreate(OBJECT, KEYPATH, TYPE, OPTIONS) \
(OCAProperty *)({ \
    typeof(OBJECT) o = (OBJECT);\
    [[OCAProperty alloc] initWithObject:o \
                              keyPathAccessor:OCAKeyPathAccessorCreateFromObject(o, KEYPATH, TYPE) \
                                      options:OPTIONS]; \
}) \





#define OCAPropertyCreateWithStructure(OBJECT, KEYPATH, MEMBER, OPTIONS) \
(OCAProperty *)({ \
    typeof(OBJECT) o = (OBJECT);\
    [[OCAProperty alloc] initWithObject:o \
                              keyPathAccessor:OCAKeyPathAccessorCreateWithStructureFromObject(o, KEYPATH, MEMBER) \
                                      options:OPTIONS]; \
}) \


