//
//  OCAIndexAccessor.h
//  Objective-Chain
//
//  Created by Martin Kiss on 17.4.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAAccessor.h"





@interface OCAIndexAccessor : OCAAccessor


#define OCAIndex(index)     ( [[OCAIndexAccessor alloc] initWithIndex:index] )

//! Uses  so can be negative and can be out of range.
- (instancetype)initWithIndex:(NSInteger)index;
@property (nonatomic, readonly, assign) NSInteger index;


@end


