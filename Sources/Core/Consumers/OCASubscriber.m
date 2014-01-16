//
//  OCASubscriber.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCASubscriber.h"
#import "OCAConnection.h"





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


+ (instancetype)subscribeClass:(Class)valueClass handler:(OCASubscriberValueHandler)valueHandler {
    return [[self alloc] initWithValueClass:valueClass valueHandler:valueHandler finishHandler:nil];
}


+ (instancetype)subscribeClass:(Class)valueClass handler:(OCASubscriberValueHandler)valueHandler finish:(OCASubscriberFinishHandler)finishHandler {
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
             @"consumedValueClass": self.valueClass,
             };
}






@end










@implementation OCAProducer (OCASubscriber)



- (OCAConnection *)subscribe:(Class)valueClass handler:(OCASubscriberValueHandler)valueHandler {
    OCASubscriber *subscriber = [[OCASubscriber alloc] initWithValueClass:valueClass valueHandler:valueHandler finishHandler:nil];
    return [[OCAConnection alloc] initWithProducer:self queue:nil transform:nil consumer:subscriber];
}


- (OCAConnection *)subscribe:(Class)valueClass handler:(OCASubscriberValueHandler)valueHandler finish:(OCASubscriberFinishHandler)finishHandler {
    OCASubscriber *subscriber = [[OCASubscriber alloc] initWithValueClass:valueClass valueHandler:valueHandler finishHandler:finishHandler];
    return [[OCAConnection alloc] initWithProducer:self queue:nil transform:nil consumer:subscriber];
}



@end


