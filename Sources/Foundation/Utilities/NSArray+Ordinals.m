//
//  NSArray+Ordinals.m
//  Objective-Chain
//
//  Created by Martin Kiss on 10.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "NSArray+Ordinals.h"





@implementation NSArray (Ordinals)





- (id)oca_valueAtIndex:(NSInteger)index {
    NSInteger realIndex = (index >= 0? index : self.count + index);
    if (realIndex < 0) return nil;
    if (realIndex >= self.count) return nil;
    
    id value = [self objectAtIndex:realIndex];
    
    if (value == NSNull.null) return nil;
    return value;
}





@end










NSUInteger OCANormalizeIndex(NSInteger index, NSUInteger length) {
    
    if (index < 0)
        index = length + index;
    
    if (index < 0)
        return 0;
    
    if (index >= length)
        index = length;
    
    return index;
}


NSRange OCANormalizeRange(NSRange range, NSUInteger length) {
    
    if (range.location > length)
        range.location = length;
    
    NSUInteger end = length - range.location;
    
    if (range.length > end)
        range.length = end;
    
    return range;
}


