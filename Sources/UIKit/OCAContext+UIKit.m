//
//  OCAContext+UIKit.m
//  Objective-Chain
//
//  Created by Martin Kiss on 15.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAContext+UIKit.h"










@implementation OCAContext (UIKit)





#pragma mark View Animations


+ (OCAContext *)noAnimations {
    return [[self alloc] initWithValueClass:nil definitionBlock:^(OCAContextExecutionBlock executionBlock) {
        [UIView performWithoutAnimation:executionBlock];
    }];
}


+ (OCAContext *)animateWithDuration:(NSTimeInterval)duration {
    return [[self alloc] initWithValueClass:nil definitionBlock:^(OCAContextExecutionBlock executionBlock) {
        [UIView animateWithDuration:duration animations:executionBlock];
    }];
}


+ (OCAContext *)animateWithDelay:(NSTimeInterval)delay duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options {
    return [[self alloc] initWithValueClass:nil definitionBlock:^(OCAContextExecutionBlock executionBlock) {
        [UIView animateWithDuration:duration delay:delay options:options animations:executionBlock completion:nil];
    }];
}





#pragma mark Core Animation


+ (OCAContext *)disableImplicitAnimations {
    return [[self alloc] initWithValueClass:nil definitionBlock:^(OCAContextExecutionBlock executionBlock) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        
        executionBlock();
        
        [CATransaction commit];
    }];
}





@end


