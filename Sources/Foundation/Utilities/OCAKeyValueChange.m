//
//  OCAKeyValueChange.m
//  Objective-Chain
//
//  Created by Martin Kiss on 29.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAKeyValueChange.h"
#import "OCAProperty.h"
#import "OCATransformer.h"
#if OCA_iOS
    #import <UIKit/UIKit.h>
#endif










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


- (instancetype)initWithChange:(OCAKeyValueChange *)change transformer:(NSValueTransformer *)transformer {
    self = [super init];
    if (self) {
        OCAAssert(change != nil, @"Missing existing change.") return nil;
        OCAAssert(transformer != nil, @"Missing transformer.") return nil;
        
        if (self.class != [change class]) {
            return [[change.class alloc] initWithChange:change transformer:transformer];
        }
        
        // Only subclasses:
        
        self->_object = change.object;
        self->_keyPath = change.keyPath;
        self->_changeDictionary = nil;
        self->_accessor = change.accessor;
        self->_kind = change.kind;
        
        if ([self isKindOfClass:[OCAKeyValueChangeSetting class]]) {
            NSValueTransformer *collectionTransformer = [OCATransformer transformArray:transformer];
            self->_latestValue = [collectionTransformer transformedValue:change.latestValue];
        }
        else {
            self->_latestValue = nil;
        }
        self->_isPrior = change.isPrior;
        
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
    OCAAssert(NO, @"Some other collection class? %@", [collection class]) return nil;
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









@interface OCAKeyValueChangeSetting ()

@property (nonatomic, readwrite, assign) BOOL previousValueWasNonNil;
@property (nonatomic, readwrite, assign) BOOL previousValueWasStoredStrongly;

@property (nonatomic, readwrite, weak) id weakPreviousValue;
@property (nonatomic, readwrite, strong) id strongPreviousValue;

@end


@implementation OCAKeyValueChangeSetting



- (instancetype)initWithObject:(NSObject *)object keyPath:(NSString *)keyPath change:(NSDictionary *)dictionary structureAccessor:(OCAStructureAccessor *)accessor {
    self = [super initWithObject:object keyPath:keyPath change:dictionary structureAccessor:accessor];
    if (self.class == [OCAKeyValueChangeSetting class]) {
        
        id old = [dictionary objectForKey:NSKeyValueChangeOldKey];
        self->_isInitial = (self.kind == NSKeyValueChangeSetting && old == nil && ! self.isPrior);
        id oldValue = (old == NSNull.null? nil : old);
        id previousValue = (accessor? [accessor accessObject:oldValue] : oldValue);
        
        self->_previousValueWasNonNil = (previousValue != nil);
        if (self->_previousValueWasNonNil) {
            self.previousValueWasStoredStrongly = [self.class isClass:[previousValue class] compatibleWithClasses:[self.class strongClasses]];
            // It's easier to whitelist few classes, than using strong or weak for everthing.
            if (self->_previousValueWasStoredStrongly) {
                self.strongPreviousValue = previousValue;
            }
            else {
                self.weakPreviousValue = previousValue; // If this gets deallocated, the above flag will tell us.
            }
        }
    }
    return self;
}


+ (NSArray *)strongClasses {
    static NSArray *strongClasses = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /// Classes that are just data types that can be stored for extended perios of time without side effects.
        // They shouln't contain any other objects.
        strongClasses = @[
                          [NSValue class],
                          [NSString class],
                          [NSUUID class],
                          [NSDate class],
                          [NSDateComponents class],
                          [NSURL class],
                          [NSIndexPath class],
                          [NSLocale class],
                          [NSNull class],
                          // NSError can contain recovery attempter
#if OCA_iOS
                          [UIColor class],
                          [UIFont class],
#endif
                          ];
    });
    return strongClasses;
}


- (OCAKeyValueChangeSetting *)asSettingChange {
    return self;
}


- (id)previousValue {
    if (self->_previousValueWasStoredStrongly) return self->_strongPreviousValue;
    else return self->_weakPreviousValue;
}


- (BOOL)previousValueHasBeenDeallocated {
    if ( ! self->_previousValueWasNonNil) return NO; // Previous was nil, so couldn't be deallocated.
    if (self->_previousValueWasStoredStrongly) return NO; // Strong couldn't be deallocated.
    return (self->_weakPreviousValue == nil); // The last option is, that it was stored weakly, but it's not there anymore.
}


- (BOOL)isLatestEqualToPrevious {
    if ([self previousValueHasBeenDeallocated]) {
        return NO;
    }
    return OCAEqual(self.previousValue, self.latestValue);
}


- (instancetype)copyWithTransformedInsertedObjects:(NSValueTransformer *)transformer {
    return [[self.class alloc] initWithChange:self transformer:transformer];
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


- (instancetype)initWithChange:(OCAKeyValueChangeInsertion *)insertion transformer:(NSValueTransformer *)transformer {
    self = [super initWithChange:insertion transformer:transformer];
    if (self) {
        
        NSValueTransformer *collectionTransformer = [OCATransformer transformArray:transformer];
        
        self->_insertedObjects = [collectionTransformer transformedValue:insertion.insertedObjects];
        self->_insertedIndexes = insertion.insertedIndexes;
    }
    return self;
}


- (OCAKeyValueChangeInsertion *)asInsertionChange {
    return self;
}


- (void)applyToProperty:(OCAProperty *)property {
    [property insertCollection:self.insertedObjects atIndexes:self.insertedIndexes];
}


- (instancetype)copyWithTransformedInsertedObjects:(NSValueTransformer *)transformer {
    return [[self.class alloc] initWithChange:self transformer:transformer];
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


- (instancetype)initWithChange:(OCAKeyValueChangeRemoval *)removal transformer:(NSValueTransformer *)transformer {
    self = [super initWithChange:removal transformer:transformer];
    if (self) {
        
        NSValueTransformer *collectionTransformer = [OCATransformer transformArray:transformer];
        
        self->_removedObjects = [collectionTransformer transformedValue:removal.removedObjects];
        self->_removedIndexes = removal.removedIndexes;
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


- (instancetype)initWithChange:(OCAKeyValueChangeReplacement *)replacement transformer:(NSValueTransformer *)transformer {
    self = [super initWithChange:replacement transformer:transformer];
    if (self) {
        
        NSValueTransformer *collectionTransformer = [OCATransformer transformArray:transformer];
        
        self->_insertedObjects = [collectionTransformer transformedValue:replacement.insertedObjects];
        self->_replacedIndexes = replacement.replacedIndexes;
    }
    return self;
}


- (OCAKeyValueChangeReplacement *)asReplacementChange {
    return self;
}


- (void)applyToProperty:(OCAProperty *)property {
    [property replaceCollectionAtIndexes:self.replacedIndexes withCollection:self.insertedObjects];
}


- (instancetype)copyWithTransformedInsertedObjects:(NSValueTransformer *)transformer {
    return [[self.class alloc] initWithChange:self transformer:transformer];
}



@end









