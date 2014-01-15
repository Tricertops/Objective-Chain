//
//  OCAActionTarget.m
//  Objective-Chain
//
//  Created by Martin Kiss on 15.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAActionTarget.h"
#import "OCAProducer+Subclass.h"
#import "OCADecomposer.h"










@implementation OCAActionTarget





- (instancetype)initWithControl:(UIControl *)control events:(UIControlEvents)events {
    self = [super init];
    if (self) {
        OCAAssert(control != nil, @"Need a control.") return nil;
        OCAAssert(events != 0, @"Need events.") return nil;
        
        //TODO: Shared
        
        self->_control = control;
        self->_events = events;
        
        [control addTarget:self action:@selector(produceValue:) forControlEvents:events];
        
        [control.decomposer addOwnedObject:self cleanup:^{
            [control removeTarget:self action:@selector(produceValue:) forControlEvents:events];
        }];
    }
    return self;
}


+ (OCAActionTarget *)existingActionTargetForControl:(UIControl *)control events:(UIControlEvents)events {
    return [control.decomposer findOwnedObjectOfClass:self usingBlock:^BOOL(OCAActionTarget *ownedTarget) {
        return (ownedTarget.events == events);
    }];
}


- (Class)valueClass {
    return self.control.class;
}


- (NSString *)descriptionName {
    return @"Action Target";
}


- (NSString *)description {
    UIControl *control = self.control;
    return [NSString stringWithFormat:@"%@ of %@ (%p) for event %@", self.shortDescription, control.class, control, @(self.events)];
}


- (NSDictionary *)debugDescriptionValues {
    return @{
             @"control": self.control.debugDescription,
             @"events": @(self.events),
             };
}





@end










@implementation UIControl (OCAActionTarget)





- (OCAProducer *)producerForEvent:(UIControlEvents)event {
    return [[OCAActionTarget alloc] initWithControl:self events:event];
}





@end


