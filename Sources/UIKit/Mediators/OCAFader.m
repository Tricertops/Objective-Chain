//
//  OCAFader.m
//  Objective-Chain
//
//  Created by Martin Kiss on 16.5.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAFader.h"
#import "OCAProducer+Subclass.h"
#import "OCADecomposer.h"
#import "OCAPredicate.h"





@implementation OCAFader





- (instancetype)initWithView:(UIView *)view visiblePredicate:(NSPredicate *)predicate duration:(NSTimeInterval)duration {
    self = [super initWithValueClass:nil];
    if (self) {
        self->_view = view;
        [view.decomposer addOwnedObject:self cleanup:nil];
        
        self->_visiblePredicate = predicate ?: [[OCAPredicate isEmpty] negate];
        self->_duration = duration;
    }
    return self;
}


+ (instancetype)fade:(UIView *)view duration:(NSTimeInterval)duration {
    return [[self alloc] initWithView:view visiblePredicate:nil duration:duration];
}


+ (instancetype)fade:(UIView *)view visible:(NSPredicate *)predicate duration:(NSTimeInterval)duration {
    return [[self alloc] initWithView:view visiblePredicate:predicate duration:duration];
}


- (void)consumeValue:(id)value {
    BOOL isVisible = [self.visiblePredicate evaluateWithObject:value];
    
    if (isVisible) [self produceValue:value];
    
    [UIView animateWithDuration:self.duration
                          delay:0
                        options:(UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         self.view.alpha = (isVisible? 1 : 0);
                     }
                     completion:^(BOOL finished) {
                         if ( ! isVisible) [self produceValue:value];
                     }];
}


- (void)finishConsumingWithError:(NSError *)error {
    
}





@end


