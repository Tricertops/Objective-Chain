//
//  OCADecomposer.m
//  Objective-Chain
//
//  Created by Martin Kiss on 8.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCADecomposer.h"
#import <objc/runtime.h>





@interface OCADecomposer ()


@property (atomic, readonly, strong) NSMapTable *ownedTable;


@end










@implementation OCADecomposer





#pragma mark Creating Decomposer


- (instancetype)initWithOwner:(id)owner {
    self = [super init];
    if (self) {
        OCAAssert( ! [owner isKindOfClass:[OCADecomposer class]], @"You are tricky, but I am trickier.") return nil;
        
        self->_owner = owner;
        self->_ownedTable = [NSMapTable strongToStrongObjectsMapTable];
    }
    return self;
}





#pragma mark Managing Owned Objects


- (void)addOwnedObject:(id)ownedObject cleanup:(OCADecomposerBlock)cleanupBlock {
    // Owned Table: Owned objects are Keys and an array of cleanup blocks is Value.
    NSMutableArray *cleanups = [self.ownedTable objectForKey:ownedObject];
    if ( ! cleanups) {
        cleanups = [[NSMutableArray alloc] init];
        [self.ownedTable setObject:cleanups forKey:ownedObject];
    }
    [cleanups addObject:cleanupBlock];
}


- (void)removeOwnedObject:(id)ownedObject {
    [self.ownedTable removeObjectForKey:ownedObject];
}





#pragma mark Decomposing


- (void)decompose {
    NSMapTable *table = self.ownedTable;
    
    for (NSMutableArray *cleanups in table.objectEnumerator) {
        for (OCADecomposerBlock cleanupBlock in cleanups) {
            cleanupBlock();
        }
    }
    
    [table removeAllObjects];
}


- (void)dealloc {
    [self decompose];
}





@end










@implementation NSObject (OCADecomposer)





- (OCADecomposer *)decomposer {
    @synchronized(self) {
        static const void * OCADecomposerAssociationKey = &OCADecomposerAssociationKey;
        OCADecomposer *decomposer = objc_getAssociatedObject(self, OCADecomposerAssociationKey);
        if ( ! decomposer) {
            decomposer = [[OCADecomposer alloc] initWithOwner:self];
            objc_setAssociatedObject(self, OCADecomposerAssociationKey, decomposer, OBJC_ASSOCIATION_RETAIN);
        }
        [self.class swizzleDeallocIfNeeded];
        return decomposer;
    }
}


+ (BOOL)swizzleDeallocIfNeeded {
    static NSMutableSet *swizzledClasses = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzledClasses = [[NSMutableSet alloc] init];
    });
    
    @synchronized(self) {
        if ([swizzledClasses containsObject:self]) return NO;
        
        Method dealloc = class_getInstanceMethod(self, NSSelectorFromString(@"dealloc"));
        Method oca_dealloc = class_getInstanceMethod(self, @selector(oca_dealloc));
        method_exchangeImplementations(dealloc, oca_dealloc);
        
        [swizzledClasses addObject:self];
        NSLog(@"Decomposer: Swizzled class %@", self);
        
        return YES;
    }
}


- (void)oca_dealloc {
    NSLog(@"Decomposer: Custom dealloc <%@ %p>", self.class, self);
    [self.decomposer decompose];
    [self oca_dealloc];
}





@end


