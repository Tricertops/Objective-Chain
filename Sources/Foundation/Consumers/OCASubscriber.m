//
//  OCASubscriber.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCASubscriber.h"





@interface OCASubscriber ()


@property (atomic, readonly, copy) OCASubscriberValueHandler valueHandler;
@property (atomic, readonly, copy) OCASubscriberFinishHandler finishHandler;


@end










@implementation OCASubscriber





#pragma mark Creating Subscriber


- (instancetype)init {
    return [self initWithValueClass:nil valueHandler:nil finishHandler:nil];
}


- (instancetype)initWithValueClass:(Class)valueClass valueHandler:(OCASubscriberValueHandler)valueHandler finishHandler:(OCASubscriberFinishHandler)finishHandler {
    self = [super init];
    if (self) {
        self->_valueClass = valueClass;
        self->_valueHandler = valueHandler;
        self->_finishHandler = finishHandler;
    }
    return self;
}


+ (instancetype)events:(OCASubscriberEventHandler)eventHandler {
    return [[self alloc] initWithValueClass:nil
                               valueHandler:^(id value){
                                   eventHandler();
                               }
                              finishHandler:nil];
}


+ (instancetype)class:(Class)valueClass handler:(OCASubscriberValueHandler)valueHandler {
    return [[self alloc] initWithValueClass:valueClass valueHandler:valueHandler finishHandler:nil];
}


+ (instancetype)class:(Class)valueClass handler:(OCASubscriberValueHandler)valueHandler finish:(OCASubscriberFinishHandler)finishHandler {
    return [[self alloc] initWithValueClass:valueClass valueHandler:valueHandler finishHandler:finishHandler];
}





#pragma mark Lifetime of Subscriber


- (Class)consumedValueClass {
    return self.valueClass;
}


- (void)consumeValue:(id)value {
    BOOL valid = [self validateObject:&value ofClass:self.valueClass];
    if ( ! valid) return;
    
    OCASubscriberValueHandler handler = self.valueHandler;
    if (handler) handler(value);
}


- (void)finishConsumingWithError:(NSError *)error {
    OCASubscriberFinishHandler handler = self.finishHandler;
    if (handler) handler(error);
}





#pragma mark Describing Subscriber


- (NSString *)descriptionName {
    return @"Subscriber";
}


- (NSString *)description {
    NSString *className = [[self.valueClass description] stringByAppendingString:@"s"] ?: @"anything";
    return [NSString stringWithFormat:@"%@ for %@", self.shortDescription, className];
    // Subscriber for NSArrays
}


- (NSDictionary *)debugDescriptionValues {
    return @{
             @"consumedValueClass": self.valueClass ?: @"nil",
             };
}






@end










@implementation OCAProducer (OCASubscriber)



- (void)subscribeEvents:(OCASubscriberEventHandler)eventHandler CONVENIENCE {
    OCASubscriber *subscriber = [[OCASubscriber alloc] initWithValueClass:nil
                                                             valueHandler:^(id value) {
                                                                 eventHandler();
                                                             }
                                                            finishHandler:nil];
    [self addConsumer:subscriber];
}


- (void)subscribe:(Class)valueClass handler:(OCASubscriberValueHandler)valueHandler CONVENIENCE {
    OCASubscriber *subscriber = [[OCASubscriber alloc] initWithValueClass:valueClass valueHandler:valueHandler finishHandler:nil];
    [self addConsumer:subscriber];
}


- (void)subscribe:(Class)valueClass handler:(OCASubscriberValueHandler)valueHandler finish:(OCASubscriberFinishHandler)finishHandler CONVENIENCE {
    OCASubscriber *subscriber = [[OCASubscriber alloc] initWithValueClass:valueClass valueHandler:valueHandler finishHandler:finishHandler];
    [self addConsumer:subscriber];
}



@end


