//
//  OCAPropertyBridge.h
//  Objective-Chain
//
//  Created by Martin Kiss on 9.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAProducer.h"
#import "OCAConsumer.h"
#import "OCAKeyPathAccessor.h"




typedef enum : NSUInteger {
    OCAPropertyOptionDefault = 0,
    
    OCAPropertyOptionIncludePreviousValue = 1 << 0,
//TODO: OCAPropertyOptionSkipInitialValue = 1 << 1,
//TODO: OCAPropertyOptionSendDuplicates = 1 << 2,
//TODO: OCAPropertyOptionObservePrior = 1 << 3,
    
} OCAPropertyOptions;






@interface OCAPropertyBridge : OCAProducer < OCAConsumer >



#pragma mark Creating Property Bridge

#define OCAProperty(OBJECT, KEYPATH, TYPE)                      OCAPropertyBridgeCreate(OBJECT, KEYPATH, TYPE, OCAPropertyOptionDefault)
#define OCAPropertyChange(OBJECT, KEYPATH, TYPE)                OCAPropertyBridgeCreate(OBJECT, KEYPATH, TYPE, OCAPropertyOptionIncludePreviousValue)
#define OCAPropertyStruct(OBJECT, KEYPATH, MEMBER)              OCAPropertyBridgeCreateWithStructure(OBJECT, KEYPATH, MEMBER, OCAPropertyOptionDefault)
#define OCAPropertyStructChange(OBJECT, KEYPATH, MEMBER)        OCAPropertyBridgeCreateWithStructure(OBJECT, KEYPATH, MEMBER, OCAPropertyOptionIncludePreviousValue)

- (instancetype)initWithObject:(NSObject *)object keyPathAccessor:(OCAKeyPathAccessor *)accessor options:(OCAPropertyOptions)options;


#pragma mark Attributes of Property Bridge

@property (atomic, readonly, weak) id object;
@property (atomic, readonly, copy) NSString *keyPath;
@property (atomic, readonly, copy) NSString *memberPath;
@property (atomic, readonly, strong) Class valueClass;
@property (atomic, readonly, assign) OCAPropertyOptions options;


#pragma mark Using Property

@property (atomic, readwrite, weak) id value;


#pragma mark Binding Properties

- (NSArray *)bindTo:(OCAPropertyBridge *)property;
- (NSArray *)bindWithTransform:(NSValueTransformer *)transformer to:(OCAPropertyBridge *)property;



@end





#define OCAPropertyBridgeCreate(OBJECT, KEYPATH, TYPE, OPTIONS) \
(OCAPropertyBridge *)({ \
    typeof(OBJECT) o = (OBJECT);\
    [[OCAPropertyBridge alloc] initWithObject:o \
                              keyPathAccessor:OCAKeyPathAccessorCreateFromObject(o, KEYPATH, TYPE) \
                                      options:OPTIONS]; \
}) \





#define OCAPropertyBridgeCreateWithStructure(OBJECT, KEYPATH, MEMBER, OPTIONS) \
(OCAPropertyBridge *)({ \
    typeof(OBJECT) o = (OBJECT);\
    [[OCAPropertyBridge alloc] initWithObject:o \
                              keyPathAccessor:OCAKeyPathAccessorCreateWithStructureFromObject(o, KEYPATH, MEMBER) \
                                      options:OPTIONS]; \
}) \


