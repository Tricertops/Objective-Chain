//
//  NSArray+Ordinals.h
//  Objective-Chain
//
//  Created by Martin Kiss on 10.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>





@interface NSArray (Ordinals)


- (id)oca_valueAtIndex:(NSInteger)index;


@end





extern NSUInteger OCANormalizeIndex(NSInteger index, NSUInteger length);
extern NSRange OCANormalizeRange(NSRange range, NSUInteger length);


