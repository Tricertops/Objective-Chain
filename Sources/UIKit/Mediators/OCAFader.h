//
//  OCAFader.h
//  Objective-Chain
//
//  Created by Martin Kiss on 16.5.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCAMediator.h"





@interface OCAFader : OCAMediator


- (instancetype)initWithView:(UIView *)view visiblePredicate:(NSPredicate *)predicate duration:(NSTimeInterval)duration;
+ (instancetype)fade:(UIView *)view duration:(NSTimeInterval)duration;
+ (instancetype)fade:(UIView *)view visible:(NSPredicate *)predicate duration:(NSTimeInterval)duration;

@property (atomic, readonly, weak) UIView *view;
@property (atomic, readonly, strong) NSPredicate *visiblePredicate;
@property (atomic, readonly, assign) NSTimeInterval duration;


@end


