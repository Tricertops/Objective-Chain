//
//  OCAKeyValueChange.m
//  Objective-Chain
//
//  Created by Martin Kiss on 29.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAKeyValueChange.h"
#import "OCAProperty.h"










@implementation OCAKeyValueChange



- (instancetype)initWithObject:(NSObject *)object keyPath:(NSString *)keyPath change:(NSDictionary *)dictionary structureAccessor:(OCAStructureAccessor *)accessor {
    self = [super init];
    if (self) {
        OCAAssert(object != nil, @"Missing object.") return nil;
        OCAAssert(keyPath.length > 0, @"Missing key-path.") return nil;
        OCAAssert(dictionary != nil, @"Missing dictionary.") return nil;
        
        NSKeyValueChange kind = [[dictionary objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
        Class class = [OCAKeyValueChange classForChangeKind:kind];
        OCAAssert(class != Nil, @"Invalid change dictionary.") return nil;
        
        if (self.class == [OCAKeyValueChange class]) {
            return [[class alloc] initWithObject:object keyPath:keyPath change:dictionary structureAccessor:accessor];
        }
        
        // Only subclasses:
        
        self->_object = object;
        self->_keyPath = keyPath;
        self->_changeDictionary = dictionary;
        self->_accessor = accessor;
        self->_kind = kind;
        
        id latestValue = [object valueForKeyPath:keyPath];
        self->_latestValue = (accessor? [accessor accessObject:latestValue] : latestValue);
        self->_isPrior = [[dictionary objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue];
        
    }
    return self;
}


+ (Class)classForChangeKind:(NSKeyValueChange)kind {
    switch (kind) {
        case NSKeyValueChangeSetting:       return [OCAKeyValueChangeSetting class];
        case NSKeyValueChangeInsertion:     return [OCAKeyValueChangeInsertion class];
        case NSKeyValueChangeRemoval:       return [OCAKeyValueChangeRemoval class];
        case NSKeyValueChangeReplacement:   return [OCAKeyValueChangeReplacement class];
    }
    return Nil;
}


- (NSArray *)arrayFromCollection:(id)collection {
    if ([collection isKindOfClass:[NSArray class]]) {
        return (NSArray *)collection;
    }
    else if ([collection isKindOfClass:[NSSet class]]) {
        return [(NSSet *)collection allObjects];
    }
    else if ([collection isKindOfClass:[NSOrderedSet class]]) {
        return [(NSOrderedSet *)collection array];
    }
    OCAAssert(NO, @"Some other collection class? %@", [collection class]);
    return nil;
}


- (OCAKeyValueChangeSetting *)asSettingChange {
    return nil;
}


- (OCAKeyValueChangeInsertion *)asInsertionChange {
    return nil;
}


- (OCAKeyValueChangeRemoval *)asRemovalChange {
    return nil;
}


- (OCAKeyValueChangeReplacement *)asReplacementChange {
    return nil;
}


- (void)applyToProperty:(OCAProperty *)property {
    property.value = self.latestValue;
}



@end









@implementation OCAKeyValueChangeSetting



- (instancetype)initWithObject:(NSObject *)object keyPath:(NSString *)keyPath change:(NSDictionary *)dictionary structureAccessor:(OCAStructureAccessor *)accessor {
    self = [super initWithObject:object keyPath:keyPath change:dictionary structureAccessor:accessor];
    if (self.class == [OCAKeyValueChangeSetting class]) {
        
        id old = [dictionary objectForKey:NSKeyValueChangeOldKey];
        self->_isInitial = (self.kind == NSKeyValueChangeSetting && old == nil && ! self.isPrior);
        id previousValue = (old == NSNull.null? nil : old);
        self->_previousValue = (accessor? [accessor accessObject:previousValue] : previousValue);
    }
    return self;
}


- (OCAKeyValueChangeSetting *)asSettingChange {
    return self;
}


- (BOOL)isLatestEqualToPrevious {
    return OCAEqual(self->_previousValue, self.latestValue);
}



@end










@implementation OCAKeyValueChangeInsertion



- (instancetype)initWithObject:(NSObject *)object keyPath:(NSString *)keyPath change:(NSDictionary *)dictionary structureAccessor:(OCAStructureAccessor *)accessor {
    self = [super initWithObject:object keyPath:keyPath change:dictionary structureAccessor:nil];
    if (self.class == [OCAKeyValueChangeInsertion class]) {
        
        self->_insertedObjects = [self arrayFromCollection:[dictionary objectForKey:NSKeyValueChangeNewKey]];
        self->_insertedIndexes = [dictionary objectForKey:NSKeyValueChangeIndexesKey];
    }
    return self;
}


- (OCAKeyValueChangeInsertion *)asInsertionChange {
    return self;
}


- (void)applyToProperty:(OCAProperty *)property {
    [property insertCollection:self.insertedObjects atIndexes:self.insertedIndexes];
}



@end










@implementation OCAKeyValueChangeRemoval



- (instancetype)initWithObject:(NSObject *)object keyPath:(NSString *)keyPath change:(NSDictionary *)dictionary structureAccessor:(OCAStructureAccessor *)accessor {
    self = [super initWithObject:object keyPath:keyPath change:dictionary structureAccessor:nil];
    if (self.class == [OCAKeyValueChangeRemoval class]) {
        
        self->_removedObjects = [self arrayFromCollection:[dictionary objectForKey:NSKeyValueChangeOldKey]];
        self->_removedIndexes = [dictionary objectForKey:NSKeyValueChangeIndexesKey];
    }
    return self;
}


- (OCAKeyValueChangeRemoval *)asRemovalChange {
    return self;
}


- (void)applyToProperty:(OCAProperty *)property {
    [property removeCollectionAtIndexes:self.removedIndexes];
}



@end










@implementation OCAKeyValueChangeReplacement



- (instancetype)initWithObject:(NSObject *)object keyPath:(NSString *)keyPath change:(NSDictionary *)dictionary structureAccessor:(OCAStructureAccessor *)accessor {
    self = [super initWithObject:object keyPath:keyPath change:dictionary structureAccessor:nil];
    if (self.class == [OCAKeyValueChangeReplacement class]) {
        
        self->_removedObjects = [self arrayFromCollection:[dictionary objectForKey:NSKeyValueChangeOldKey]];
        self->_insertedObjects = [self arrayFromCollection:[dictionary objectForKey:NSKeyValueChangeNewKey]];
        self->_replacedIndexes = [dictionary objectForKey:NSKeyValueChangeIndexesKey];
    }
    return self;
}


- (OCAKeyValueChangeReplacement *)asReplacementChange {
    return self;
}


- (void)applyToProperty:(OCAProperty *)property {
    [property replaceCollectionAtIndexes:self.replacedIndexes withCollection:self.insertedObjects];
}



@end









