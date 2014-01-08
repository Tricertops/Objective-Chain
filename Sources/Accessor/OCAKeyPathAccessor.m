//
//  OCAKeyPathAccessor.m
//  Objective-Chain
//
//  Created by Martin Kiss on 8.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAKeyPathAccessor.h"




@interface OCAKeyPathAccessor ()


@property (atomic, readonly, strong) Class objectClass;
@property (atomic, readonly, strong) Class valueClass;


@end










@implementation OCAKeyPathAccessor





#pragma mark Creating Key-Path Accessor


- (instancetype)initWithObjectClass:(Class)objectClass keyPath:(NSString *)keyPath valueClass:(Class)valueClass {
    self = [super init];
    if (self) {
        OCAAssert(keyPath.length > 0, @"Missing key-path.");
        
        self->_objectClass = objectClass;
        self->_keyPath = keyPath;
        self->_valueClass = valueClass;
    }
    return self;
}





#pragma mark Using Accessor


- (id)accessObject:(id)object {
    if ( ! object) return nil;
    
    return [object valueForKeyPath:self.keyPath];
}


- (id)modifyObject:(id)object withValue:(id)value {
    if ( ! object) return nil;
    
    [object setValue:value forKeyPath:self.keyPath];
    
    return object;
}





@end


