//
//  OCAIndexAccessor.m
//  Objective-Chain
//
//  Created by Martin Kiss on 17.4.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAIndexAccessor.h"
#import "NSArray+Ordinals.h"





@implementation OCAIndexAccessor





- (instancetype)initWithIndex:(NSInteger)index {
    self = [super init];
    if (self) {
        self->_index = index;
    }
    return self;
}


- (Class)objectClass {
    return [NSArray class];
}





- (id)accessObject:(NSArray *)array {
    return [array oca_valueAtIndex:self.index];
}


- (id)modifyObject:(NSArray *)array withValue:(id)value {
    NSMutableArray *mutable = [array mutableCopy];
    NSUInteger count = array.count;
    NSInteger index = self.index;
    
    NSInteger realIndex = (index >= 0? index : count + index);
    if (realIndex < 0) return array;
    if (realIndex >= count) return array;
    
    [mutable replaceObjectAtIndex:index withObject:(value ?: NSNull.null)];
    return mutable;
}





@end


