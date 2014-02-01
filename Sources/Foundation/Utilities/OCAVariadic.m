//
//  OCAVariadic.m
//  Objective-Chain
//
//  Created by Martin Kiss on 1.2.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAVariadic.h"





NSMutableArray * OCAArrayFromVariadicList(id first, va_list list) {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    id object = first;
    while (object) {
        if ([object isKindOfClass:[NSArray class]]) {
            [array addObjectsFromArray:(NSArray *)object];
        }
        else {
            [array addObject:object];
        }
        object = va_arg(list, id);
    }
    return array;
}


