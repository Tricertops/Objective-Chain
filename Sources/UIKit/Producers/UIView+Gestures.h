//
//  UIView+Gestures.h
//  Objective-Chain
//
//  Created by Martin Kiss on 4.12.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCATargetter.h"





@interface UIView (Gestures)


- (OCAProducer *)onTap;
- (OCAProducer *)onDoubleTap;
- (OCAProducer *)onTwinTap;
- (OCAProducer *)callbackForTaps:(NSUInteger)taps touches:(NSUInteger)touches;

- (OCAProducer *)onSwipeUp;
- (OCAProducer *)onSwipeDown;
- (OCAProducer *)onSwipeLeft;
- (OCAProducer *)onSwipeRight;
- (OCAProducer *)callbackForSwipe:(UISwipeGestureRecognizerDirection)direction touches:(NSUInteger)touches;

- (OCAProducer *)onHold;
- (OCAProducer *)onTapAndHold;
- (OCAProducer *)onHoldFor:(NSTimeInterval)duration;
- (OCAProducer *)callbackForHold:(NSTimeInterval)duration taps:(NSUInteger)taps touches:(NSUInteger)touches movement:(CGFloat)allowable;

- (OCAProducer *)onZoomIn;
- (OCAProducer *)onZoomOut;
- (OCAProducer *)onZoomAbove:(CGFloat)scale;
- (OCAProducer *)onZoomBelow:(CGFloat)scale;
- (OCAProducer *)callbackForZoomWithPredicate:(NSPredicate *)predicate;

- (OCAProducer *)onRotateLeft;
- (OCAProducer *)onRotateRight;
- (OCAProducer *)onRotateLeft:(CGFloat)degrees;
- (OCAProducer *)onRotateRight:(CGFloat)degrees;
- (OCAProducer *)callbackForRotationWithPredicate:(NSPredicate *)predicate;


@end


