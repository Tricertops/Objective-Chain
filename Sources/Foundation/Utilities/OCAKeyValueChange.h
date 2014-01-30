//
//  OCAKeyValueChange.h
//  Objective-Chain
//
//  Created by Martin Kiss on 29.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAObject.h"
#import "OCAStructureAccessor.h"
@class OCAKeyValueChangeSetting;
@class OCAKeyValueChangeInsertion;
@class OCAKeyValueChangeRemoval;
@class OCAKeyValueChangeReplacement;





@interface OCAKeyValueChange : OCAObject


- (instancetype)initWithObject:(NSObject *)object keyPath:(NSString *)keyPath change:(NSDictionary *)dictionary structureAccessor:(OCAStructureAccessor *)accessor;
@property (nonatomic, readonly, strong) id object;
@property (nonatomic, readonly, copy) NSString *keyPath;
@property (nonatomic, readonly, copy) NSDictionary *changeDictionary;
@property (nonatomic, readonly, strong) OCAStructureAccessor *accessor;

@property (nonatomic, readonly, strong) id latestValue;
@property (nonatomic, readonly) BOOL isPrior;
@property (nonatomic, readonly) NSKeyValueChange kind;

- (OCAKeyValueChangeSetting *)asSettingChange;
- (OCAKeyValueChangeInsertion *)asInsertionChange;
- (OCAKeyValueChangeRemoval *)asRemovalChange;
- (OCAKeyValueChangeReplacement *)asReplacementChange;


@end





@interface OCAKeyValueChangeSetting : OCAKeyValueChange


@property (nonatomic, readonly, assign) BOOL isInitial;
@property (nonatomic, readonly, strong) id previousValue;

- (BOOL)isLatestEqualToPrevious;


@end





@interface OCAKeyValueChangeInsertion : OCAKeyValueChange


@property (nonatomic, readonly, strong) NSArray *insertedObjects;
@property (nonatomic, readonly, strong) NSIndexSet *insertedIndexes;


@end





@interface OCAKeyValueChangeRemoval : OCAKeyValueChange


@property (nonatomic, readonly, strong) NSArray *removedObjects;
@property (nonatomic, readonly, strong) NSIndexSet *removedIndexes;


@end





@interface OCAKeyValueChangeReplacement : OCAKeyValueChange


@property (nonatomic, readonly, strong) NSArray *removedObjects;
@property (nonatomic, readonly, strong) NSArray *insertedObjects;
@property (nonatomic, readonly, strong) NSIndexSet *replacedIndexes;


@end




