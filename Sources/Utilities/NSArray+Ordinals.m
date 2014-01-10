//
//  NSArray+Ordinals.m
//  Objective-Chain
//
//  Created by Martin Kiss on 10.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "NSArray+Ordinals.h"





@implementation NSArray (Ordinals)





- (id)valueAtIndex:(NSInteger)index {
    NSInteger realIndex = (index >= 0? index : self.count + index);
    if (realIndex < 0) return nil;
    if (realIndex >= self.count) return nil;
    
    id value = [self objectAtIndex:realIndex];
    
    if (value == NSNull.null) return nil;
    return value;
}


- (id)first {
    return [self valueAtIndex:0];
}


- (id)second {
    return [self valueAtIndex:1];
}


- (id)third {
    return [self valueAtIndex:2];
}


- (id)fourth {
    return [self valueAtIndex:3];
}


- (id)fifth {
    return [self valueAtIndex:4];
}


- (id)sixth {
    return [self valueAtIndex:5];
}


- (id)last {
    return [self valueAtIndex:-1];
}





@end
