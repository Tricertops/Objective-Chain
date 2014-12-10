//
//  UIView+Gestures.m
//  Objective-Chain
//
//  Created by Martin Kiss on 4.12.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "UIView+Gestures.h"
#import "OCATransformer.h"
#import "OCAPredicate.h"
#import "OCABridge.h"
#import "OCAInvoker.h"
#import "OCAFilter.h"
#import "OCACommand.h"
#import <objc/runtime.h>





@implementation UIView (Gestures)


- (NSMutableDictionary *)oca_gestures {
    NSMutableDictionary *gestures = objc_getAssociatedObject(self, _cmd);
    if ( ! gestures) {
        gestures = [NSMutableDictionary new];
        objc_setAssociatedObject(self, _cmd, gestures, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return gestures;
}

- (UIGestureRecognizer *)oca_gestureForKey:(NSString *)key create:(UIGestureRecognizer *(^)(void))block {
    NSMutableDictionary *gestures = [self oca_gestures];
    UIGestureRecognizer *gesture = [gestures objectForKey:key];
    if ( ! gesture) {
        gesture = block();
        [self addGestureRecognizer:gesture];
        [gestures setObject:gesture forKey:key];
    }
    return gesture;
}


- (OCAProducer *)onTap {
    return [self callbackForTaps:1 touches:1];
}

- (OCAProducer *)onDoubleTap {
    return [self callbackForTaps:2 touches:1];
}

- (OCAProducer *)onTwinTap {
    return [self callbackForTaps:1 touches:2];
}

- (OCAProducer *)callbackForTaps:(NSUInteger)taps touches:(NSUInteger)touches {
    NSString *key = [NSString stringWithFormat:@"tap:%lu:%lu", (unsigned long)taps, (unsigned long)touches];
    UIGestureRecognizer *gesture = [self oca_gestureForKey:key create:^UIGestureRecognizer *{
        UITapGestureRecognizer *tap = [UITapGestureRecognizer new];
        tap.numberOfTapsRequired = taps;
        tap.numberOfTouchesRequired = touches;
        return tap;
    }];
    return gesture.callback;
}


- (OCAProducer *)onSwipeUp {
    return [self callbackForSwipe:UISwipeGestureRecognizerDirectionUp touches:1];
}

- (OCAProducer *)onSwipeDown {
    return [self callbackForSwipe:UISwipeGestureRecognizerDirectionDown touches:1];
}

- (OCAProducer *)onSwipeLeft {
    return [self callbackForSwipe:UISwipeGestureRecognizerDirectionLeft touches:1];
}

- (OCAProducer *)onSwipeRight {
    return [self callbackForSwipe:UISwipeGestureRecognizerDirectionRight touches:1];
}

- (OCAProducer *)callbackForSwipe:(UISwipeGestureRecognizerDirection)direction touches:(NSUInteger)touches {
    NSString *key = [NSString stringWithFormat:@"swipe:%lu", (unsigned long)direction];
    UIGestureRecognizer *gesture = [self oca_gestureForKey:key create:^UIGestureRecognizer *{
        UISwipeGestureRecognizer *swipe = [UISwipeGestureRecognizer new];
        swipe.direction = direction;
        swipe.numberOfTouchesRequired = touches;
        return swipe;
    }];
    return gesture.callback;
}


- (OCAProducer *)onHold {
    return [self callbackForHold:0.5 taps:0 touches:1 movement:10]; // Defaults.
}

- (OCAProducer *)onTapAndHold {
    return [self callbackForHold:0.5 taps:1 touches:1 movement:10];
}

- (OCAProducer *)onHoldFor:(NSTimeInterval)duration {
        return [self callbackForHold:duration taps:0 touches:1 movement:10];
}

- (OCAProducer *)callbackForHold:(NSTimeInterval)duration taps:(NSUInteger)taps touches:(NSUInteger)touches movement:(CGFloat)movement {
    NSString *key = [NSString stringWithFormat:@"hold:%g:%lu:%lu:%g", duration, (unsigned long)taps, (unsigned long)touches, movement];
    UIGestureRecognizer *gesture = [self oca_gestureForKey:key create:^UIGestureRecognizer *{
        UILongPressGestureRecognizer *hold = [UILongPressGestureRecognizer new];
        hold.minimumPressDuration = duration;;
        hold.numberOfTouchesRequired = touches;
        hold.numberOfTapsRequired = taps;
        hold.allowableMovement = movement;
        return hold;
    }];
    return gesture.callback;
}


static CGFloat const OCAViewDefaultZoomFactor = 1.5;

- (OCAProducer *)onZoomIn {
    return [self onZoomAbove:OCAViewDefaultZoomFactor];
}

- (OCAProducer *)onZoomOut {
    return [self onZoomBelow:1/OCAViewDefaultZoomFactor];
}

- (OCAProducer *)onZoomAbove:(CGFloat)scale {
    return [self callbackForZoomWithPredicate:[OCAPredicate isGreaterThanOrEqual:@(scale)]];
}

- (OCAProducer *)onZoomBelow:(CGFloat)scale {
    return [self callbackForZoomWithPredicate:[OCAPredicate isLessThanOrEqual:@(scale)]];
}

- (OCAProducer *)callbackForZoomWithPredicate:(NSPredicate *)predicate {
    UIGestureRecognizer *gesture = [self oca_gestureForKey:@"zoom" create:^UIGestureRecognizer *{
        return [UIPinchGestureRecognizer new];
    }];
    
    OCACommand *bridge = [OCACommand commandForClass:[gesture class]];
    [[[gesture.producer transformValues:
       [OCATransformer access:OCAKeyPath(UIPinchGestureRecognizer, scale, CGFloat)],
       nil]
      filterValues:predicate]
     connectToMany:
     OCAInvocation(bridge, sendValue:gesture),
     OCAInvocation(gesture, setEnabled:NO),
     OCAInvocation(gesture, setEnabled:YES),
     nil];
    
    return bridge;
}


static CGFloat const OCAViewDefaultRotationAngle = 30;

- (OCAProducer *)onRotateLeft {
    return [self onRotateLeft:OCAViewDefaultRotationAngle];
}

- (OCAProducer *)onRotateRight {
    return [self onRotateRight:OCAViewDefaultRotationAngle];
}

- (OCAProducer *)onRotateLeft:(CGFloat)degrees {
    return [self callbackForRotationWithPredicate:[OCAPredicate isGreaterThanOrEqual:@(degrees)]];
}

- (OCAProducer *)onRotateRight:(CGFloat)degrees {
    return [self callbackForRotationWithPredicate:[OCAPredicate isLessThanOrEqual:@(-degrees)]];
}

- (OCAProducer *)callbackForRotationWithPredicate:(NSPredicate *)predicate {
    UIGestureRecognizer *gesture = [self oca_gestureForKey:@"rotation" create:^UIGestureRecognizer *{
        return [UIRotationGestureRecognizer new];
    }];
    
    OCACommand *bridge = [OCACommand commandForClass:[gesture class]];
    [[[gesture.producer transformValues:
       [OCATransformer access:OCAKeyPath(UIRotationGestureRecognizer, rotation, CGFloat)],
       [OCAMath toDegrees],
       nil]
      filterValues:predicate]
     connectToMany:
     OCAInvocation(bridge, sendValue:gesture),
     OCAInvocation(gesture, setEnabled:NO),
     OCAInvocation(gesture, setEnabled:YES),
     nil];
    
    return bridge;
}



@end


