//
//  OCAProperty.h
//  Objective-Chain
//
//  Created by Martin Kiss on 9.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAProducer.h"
#import "OCAKeyPathAccessor.h"
#import "OCAKeyValueChange.h"










@interface OCAProperty : OCAProducer < OCAConsumer >



#pragma mark Creating Property Bridge

#define OCAProperty(OBJECT, KEYPATH, TYPE)                  OCAPropertyCreate(OBJECT, KEYPATH, TYPE, NO)
#define OCAPropertyPrior(OBJECT, KEYPATH, TYPE)             OCAPropertyCreate(OBJECT, KEYPATH, TYPE, YES)

#define OCAPropertyStruct(OBJECT, KEYPATH, MEMBER)          OCAPropertyCreateWithStructure(OBJECT, KEYPATH, MEMBER, NO)
#define OCAPropertyStructPrior(OBJECT, KEYPATH, MEMBER)     OCAPropertyCreateWithStructure(OBJECT, KEYPATH, MEMBER, YES)

- (instancetype)initWithObject:(NSObject *)object keyPathAccessor:(OCAKeyPathAccessor *)accessor isPrior:(BOOL)isPrior;


#pragma mark Attributes of Property Bridge

@property (atomic, readonly, weak) id object;
@property (atomic, readonly, copy) NSString *keyPath;
@property (atomic, readonly, copy) NSString *memberPath;
@property (atomic, readonly, strong) Class valueClass;
@property (atomic, readonly, assign) BOOL isPrior;

@property (atomic, readonly, strong) OCAKeyPathAccessor *accessor;


#pragma mark Using Property

@property (atomic, readwrite, weak) id value;
- (void)repeatLastValue;


#pragma mark Using Property as a Collection

- (BOOL)isCollection;
@property (atomic, readwrite, weak) NSMutableArray *collection;
- (NSUInteger)countOfCollection;
- (id)objectInCollectionAtIndex:(NSUInteger)index;
- (void)insertObject:(id)object inCollectionAtIndex:(NSUInteger)index;
- (void)removeObjectFromCollectionAtIndex:(NSUInteger)index;
- (void)replaceObjectInCollectionAtIndex:(NSUInteger)index withObject:(id)object;


#pragma mark Deriving Producers

- (OCAProducer *)produceLatest;
- (OCAProducer *)producePreviousWithLatest;
- (OCAProducer *)produceKeyPath;
- (OCAProducer *)produceObject;
- (OCAProducer *)produceChanges;


#pragma mark Binding Properties

- (void)bindWith:(OCAProperty *)property CONVENIENCE;
- (void)bindTransformed:(NSValueTransformer *)transformer with:(OCAProperty *)property CONVENIENCE;
- (void)bindThrottled:(OCAThrottle *)throttle transformed:(NSValueTransformer *)transformer with:(OCAProperty *)property;


@end





#define OCAPropertyCreate(OBJECT, KEYPATH, TYPE, PRIOR) \
(OCAProperty *)({ \
    typeof(OBJECT) o = (OBJECT);\
    [[OCAProperty alloc] initWithObject:o \
                              keyPathAccessor:OCAKeyPathAccessorCreateFromObject(o, KEYPATH, TYPE) \
                                      isPrior:PRIOR]; \
}) \





#define OCAPropertyCreateWithStructure(OBJECT, KEYPATH, MEMBER, PRIOR) \
(OCAProperty *)({ \
    typeof(OBJECT) o = (OBJECT);\
    [[OCAProperty alloc] initWithObject:o \
                              keyPathAccessor:OCAKeyPathAccessorCreateWithStructureFromObject(o, KEYPATH, MEMBER) \
                                      isPrior:PRIOR]; \
}) \


