//
//  OCAVariadic.h
//  Objective-Chain
//
//  Created by Martin Kiss on 1.2.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>





/// Returns string formatted using variable argument list format. Pass the formattign string as an argument.
#define OCAStringFromFormat(format) \
(NSString *)({ \
    va_list __vargs; \
    va_start(__vargs, format); \
    NSString *__string = [[NSString alloc] initWithFormat:format arguments:__vargs]; \
    va_end(__vargs); \
    __string; \
})



/// Collects variable argument list that begins with `first` into mutable array. Any arrays found in the list are expanded.
#define OCAArrayFromVariadicArguments(first) \
(NSMutableArray *)({ \
    va_list list; \
    va_start(list, first); \
    NSMutableArray *array = OCAArrayFromVariadicList(first, list); \
    va_end(list); \
    array; \
})



/// Helper macro for providing an array to variable argument method. Such method must handle these cases, for example using OCAArrayFromVariadicArguments.
#define OCAVariadic(ARRAY)     (id)(ARRAY), nil



/// Function that is used by OCAArrayFromVariadicArguments. Collects object from variadic list into mutable array. Any arrays found in the list are epanded.
extern NSMutableArray * OCAArrayFromVariadicList(id first, va_list list);


