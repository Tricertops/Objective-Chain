//
//  OCAKeyValueChange.m
//  Objective-Chain
//
//  Created by Martin Kiss on 29.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAKeyValueChange.h"





@implementation OCAKeyValueChange



- (instancetype)initWithObject:(NSObject *)object keyPath:(NSString *)keyPath change:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        OCAAssert(object != nil, @"Missing object.") return nil;
        OCAAssert(keyPath.length > 0, @"Missing key-path.") return nil;
        OCAAssert(dictionary != nil, @"Missing dictionary.") return nil;
        
        NSKeyValueChange kind = [[dictionary objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
        Class class = [OCAKeyValueChange classForChangeKind:kind];
        OCAAssert(class != Nil, @"Invalid change dictionary.") return nil;
        
        if (self.class == [OCAKeyValueChange class]) {
            return [[class alloc] initWithObject:object keyPath:keyPath change:dictionary];
        }
        
        // Only subclasses:
        
        self->_object = object;
        self->_keyPath = keyPath;
        self->_changeDictionary = dictionary;
        self->_kind = kind;
        self->_latestValue = [object valueForKeyPath:keyPath];
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


- (NSArray *)arrayFromCollection:(id)colection {
    if ([colection isKindOfClass:[NSArray class]]) {
        return (NSArray *)colection;
    }
    else if ([colection isKindOfClass:[NSSet class]]) {
        return [(NSSet *)colection allObjects];
    }
    else if ([colection isKindOfClass:[NSOrderedSet class]]) {
        return [(NSOrderedSet *)colection array];
    }
    OCAAssert(NO, @"Some other collection class? %@", [collection class]);
    return nil;
}



@end









@implementation OCAKeyValueChangeSetting



- (instancetype)initWithObject:(NSObject *)object keyPath:(NSString *)keyPath change:(NSDictionary *)dictionary {
    self = [super initWithObject:object keyPath:keyPath change:dictionary];
    if (self.class == [OCAKeyValueChangeSetting class]) {
        
        id old = [dictionary objectForKey:NSKeyValueChangeOldKey];
        self->_isInitial = (self.kind == NSKeyValueChangeSetting && old && ! self.isPrior);
        self->_previousValue = (old == NSNull.null? nil : old);
    }
    return self;
}



@end










@implementation OCAKeyValueChangeInsertion



- (instancetype)initWithObject:(NSObject *)object keyPath:(NSString *)keyPath change:(NSDictionary *)dictionary {
    self = [super initWithObject:object keyPath:keyPath change:dictionary];
    if (self.class == [OCAKeyValueChangeInsertion class]) {
        
        self->_insertedObjects = [self arrayFromCollection:[dictionary objectForKey:NSKeyValueChangeNewKey]];
        self->_insertedIndexes = [dictionary objectForKey:NSKeyValueChangeIndexesKey];
    }
    return self;
}



@end










@implementation OCAKeyValueChangeRemoval



- (instancetype)initWithObject:(NSObject *)object keyPath:(NSString *)keyPath change:(NSDictionary *)dictionary {
    self = [super initWithObject:object keyPath:keyPath change:dictionary];
    if (self.class == [OCAKeyValueChangeRemoval class]) {
        
        self->_removedObjects = [self arrayFromCollection:[dictionary objectForKey:NSKeyValueChangeOldKey]];
        self->_removedIndexes = [dictionary objectForKey:NSKeyValueChangeIndexesKey];
    }
    return self;
}



@end










@implementation OCAKeyValueChangeReplacement



- (instancetype)initWithObject:(NSObject *)object keyPath:(NSString *)keyPath change:(NSDictionary *)dictionary {
    self = [super initWithObject:object keyPath:keyPath change:dictionary];
    if (self.class == [OCAKeyValueChangeReplacement class]) {
        
        self->_newObjects = [self arrayFromCollection:[dictionary objectForKey:NSKeyValueChangeNewKey]];
        self->_oldObjects = [self arrayFromCollection:[dictionary objectForKey:NSKeyValueChangeOldKey]];
        self->_replacedIndexes = [dictionary objectForKey:NSKeyValueChangeIndexesKey];
    }
    return self;
}



@end









