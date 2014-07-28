//
//  OCATargetter.m
//  Objective-Chain
//
//  Created by Martin Kiss on 15.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCATargetter.h"
#import "OCAProducer+Subclass.h"
#import "OCADecomposer.h"
#import "OCABridge.h"
#import "OCATransformer.h"
#import "OCAHub.h"
#import "OCAProperty.h"
#import "OCAPredicate.h"
#import "OCAFilter.h"










@implementation OCATargetter





- (instancetype)initWithOwner:(NSObject *)owner {
    self = [super init];
    if (self) {
        OCAAssert(owner != nil, @"Need an owner.") return nil;
        
        self->_owner = owner;
        
        [owner.decomposer addOwnedObject:self cleanup:^(__unsafe_unretained UIControl *owner){
            // No cleanup.
        }];
    }
    return self;
}


+ (instancetype)targetForControl:(UIControl *)control events:(UIControlEvents)events {
    OCATargetter *target = [[OCATargetter alloc] initWithOwner:control];
    [control addTarget:target action:target.action forControlEvents:events];
    return target;
}


+ (instancetype)targetForBarButtonItem:(UIBarButtonItem *)barButtonItem {
    OCATargetter *target = [[OCATargetter alloc] initWithOwner:barButtonItem];
    barButtonItem.target = target;
    barButtonItem.action = target.action;
    return target;
}


+ (instancetype)targetGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    OCATargetter *target = [[OCATargetter alloc] initWithOwner:gestureRecognizer];
    [gestureRecognizer addTarget:target action:target.action];
    return target;
}


- (SEL)action {
    return @selector(produceValue:);
}



- (Class)valueClass {
    return [self.owner class];
}


- (NSString *)descriptionName {
    return @"Targetter";
}


- (NSString *)description {
    UIControl *owner = self.owner;
    return [NSString stringWithFormat:@"%@ of %@ (%p)", self.shortDescription, owner.class, owner];
}


- (NSDictionary *)debugDescriptionValues {
    return @{
             @"owner": [self.owner debugDescription],
             };
}





@end










@implementation UIControl (OCATargetter)



- (OCATargetter *)producerForEvent:(UIControlEvents)event {
    OCATargetter *target = [[OCATargetter alloc] initWithOwner:self];
    [self addTarget:target action:target.action forControlEvents:event];
    return target;
}



@end










@implementation UIButton (OCATargetter)



- (OCATargetter *)producer {
    OCATargetter *target = [[OCATargetter alloc] initWithOwner:self];
    [self addTarget:target action:target.action forControlEvents:UIControlEventTouchUpInside];
    return target;
}



@end










@implementation UIBarButtonItem (OCATargetter)


- (OCATargetter *)producer {
    OCATargetter *target = [[OCATargetter alloc] initWithOwner:self];
    self.target = target;
    self.action = target.action;
    return target;
}


@end










@implementation UIGestureRecognizer (OCATargetter)


- (OCATargetter *)producer {
    OCATargetter *target = [[OCATargetter alloc] initWithOwner:self];
    [self addTarget:target action:target.action];
    return target;
}

- (OCAProducer *)producerForState:(UIGestureRecognizerState)state {
    OCAKeyPathAccessor *accessor = OCAKeyPath(UIGestureRecognizer, state, UIGestureRecognizerState);
    NSPredicate *isRecognized = [OCAPredicate isEqualTo:@(state)];
    NSPredicate *isGestureRecognized = [OCAPredicate compare:accessor using:isRecognized];
    OCATargetter *target = [[OCATargetter alloc] initWithOwner:self];
    [self addTarget:target action:target.action];
    OCAFilter *filter = [[OCAFilter alloc] initWithPredicate:isGestureRecognized];
    [target addConsumer:filter];
    return filter;
}

- (OCAProducer *)callback {
    return [self producerForState:UIGestureRecognizerStateRecognized];
}


@end










@implementation UITextField (OCATargetter)


- (OCAProducer *)producerForText {
    OCATargetter *target = [[OCATargetter alloc] initWithOwner:self];
    [self addTarget:target action:target.action forControlEvents:UIControlEventEditingChanged];
    
    OCABridge *bridge = [[OCABridge alloc] initWithTransformer:[OCATransformer access:OCAKeyPath(UITextField, text, NSString)]];
    [target addConsumer:bridge];
    
    OCAHub *merged = [[OCAHub alloc] initWithType:OCAHubTypeMerge
                                        producers:@[
                                                    bridge,
                                                    OCAProperty(self, text, NSString),
                                                    ]];
    return merged;
}


- (OCAProducer *)producerForEndEditing {
    OCATargetter *target = [[OCATargetter alloc] initWithOwner:self];
    [self addTarget:target action:target.action forControlEvents:UIControlEventEditingDidEnd];
    
    OCABridge *bridge = [[OCABridge alloc] initWithTransformer:[OCATransformer access:OCAKeyPath(UITextField, text, NSString)]];
    [target addConsumer:bridge];
    return bridge;
}


@end










@implementation UISlider (OCATargetter)


- (OCAProducer *)producerForValue {
    OCATargetter *target = [[OCATargetter alloc] initWithOwner:self];
    [self addTarget:target action:target.action forControlEvents:UIControlEventValueChanged];
    
    OCABridge *bridge = [[OCABridge alloc] initWithTransformer:[OCATransformer access:OCAKeyPath(UISlider, value, float)]];
    [target addConsumer:bridge];
    return bridge;
}


@end










@implementation UIStepper (OCATargetter)


- (OCAProducer *)producerForValue {
    OCATargetter *target = [[OCATargetter alloc] initWithOwner:self];
    [self addTarget:target action:target.action forControlEvents:UIControlEventValueChanged];
    
    OCABridge *bridge = [[OCABridge alloc] initWithTransformer:[OCATransformer access:OCAKeyPath(UIStepper, value, double)]];
    [target addConsumer:bridge];
    return bridge;
}


@end


