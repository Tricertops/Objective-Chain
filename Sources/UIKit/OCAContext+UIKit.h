//
//  OCAContext+UIKit.h
//  Objective-Chain
//
//  Created by Martin Kiss on 15.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OCAContext.h"





@interface OCAContext (UIKit)



#pragma mark View Animations

+ (OCAContext *)noAnimations;
+ (OCAContext *)animateWithDuration:(NSTimeInterval)duration;
+ (OCAContext *)animateWithDelay:(NSTimeInterval)delay duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options;
//TODO: Animate with spring animation
//TODO: Animate with System animation


#pragma mark Core Animation

+ (OCAContext *)disableImplicitAnimations;



@end


