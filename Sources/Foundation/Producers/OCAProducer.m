//
//  OCAProducer.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAProducer+Subclass.h"
#import "OCAHub.h"
#import "OCABridge.h"
#import "OCAContext.h"
#import "OCAFilter.h"
#import "OCAThrottle.h"
#import "OCASubscriber.h"
#import "OCAInvoker.h"
#import "OCASwitch.h"
#import "OCATransformer+Core.h"
#import "OCAPredicate.h"
#import "OCAVariadic.h"





@interface OCAProducer ()


@property (atomic, readwrite, assign) NSUInteger numberOfSentValues;
@property (atomic, readwrite, assign) BOOL isFinished;
@property (atomic, readwrite, strong) NSError *error;

@property (atomic, readonly, strong) NSMutableArray *mutableConsumers;


@end










@implementation OCAProducer





#pragma mark Creating Producer


- (instancetype)init {
    return [self initWithValueClass:nil];
}


- (instancetype)initWithValueClass:(Class)valueClass {
    self = [super init];
    if (self) {
        OCAAssert(self.class != [OCAProducer class], @"Cannot instantinate abstract class. You may want to use OCACommand to produce values manually.") return nil;
        
        self->_valueClass = valueClass;
        self->_mutableConsumers = [[NSMutableArray alloc] init];
    }
    return self;
}





#pragma mark Managing Consumers


- (NSArray *)consumers {
    return [self.mutableConsumers copy];
}


- (id<OCAConsumer>)replacementConsumerForConsumer:(id<OCAConsumer>)consumer {
    OCAAssert([self isClass:self.valueClass compatibleWithClass:[consumer consumedValueClass]], @"Incompatible classes: %@ to %@", self.valueClass, [consumer consumedValueClass]) return nil;
    return consumer;
}


- (void)addConsumer:(id<OCAConsumer>)consumer {
    if ( ! consumer) return;
    consumer = [self replacementConsumerForConsumer:consumer];
    if ( ! consumer) return;
    
    [self willAddConsumer:consumer];
    
    NSMutableArray *consumers = self.mutableConsumers;
    @synchronized(consumers) {
        [consumers addObject:consumer];
    }
    
    [self didAddConsumer:consumer];
}


- (void)willAddConsumer:(id<OCAConsumer>)consumer {
    
}


- (void)didAddConsumer:(id<OCAConsumer>)consumer {
    if (self.numberOfSentValues > 0) {
        // It there was at least one sent value, send the last one.
        [consumer consumeValue:self.lastValue];
    }
    if (self.isFinished) {
        // I we already finished remove immediately.
        [consumer finishConsumingWithError:self.error];
        [self removeConsumer:consumer];
    }
}


- (void)removeConsumer:(id<OCAConsumer>)consumer {
    [self willRemoveConsumer:consumer];
    
    NSMutableArray *consumers = self.mutableConsumers;
    @synchronized(consumers) {
        [consumers removeObjectIdenticalTo:consumer];
    }
    
    [self didRemoveConsumer:consumer];
}


- (void)willRemoveConsumer:(id<OCAConsumer>)consumer {
    
}


- (void)didRemoveConsumer:(id<OCAConsumer>)consumer {
    
}


- (void)removeAllConsumers {
    for (id<OCAConsumer> consumer in self.consumers) {
        [self removeConsumer:consumer];
    }
}





#pragma mark Lifetime of Producer


- (BOOL)validateProducedValue:(id)value {
    return [self validateObject:&value ofClass:self.valueClass];
}


- (NSArray *)validClassesForConsumer:(id<OCAConsumer>)consumer {
    if ([consumer respondsToSelector:@selector(consumedValueClasses)]) {
        return [consumer consumedValueClasses];
    }
    else {
        Class class = [consumer consumedValueClass];
        return (class? @[ class ] : nil);
    }
}


- (void)produceValue:(id)value {
    if ( ! [self validateProducedValue:value]) return;
    
    if (self.isFinished) return;
    self.lastValue = value;
    self.numberOfSentValues ++;
    
    for (id<OCAConsumer> consumer in [self.mutableConsumers copy]) {
        id consumedValue = value; // Always new variable, it will be manipulated by reference.
        
        //TODO: Special class to declare, that it is passed without changes.
        
        if ([self validateObject:&consumedValue ofClasses:[self validClassesForConsumer:consumer]]) {
            [consumer consumeValue:consumedValue];
        }
    }
}


- (void)finishProducingWithError:(NSError *)error {
    if (self.isFinished) return;
    
    self.isFinished = YES;
    self.error = error;
    
    NSArray *consumers = [self.mutableConsumers copy];
    [self.mutableConsumers setArray:@[]];
    
    for (id<OCAConsumer> consumer in consumers) {
        [consumer finishConsumingWithError:error];
        [self removeConsumer:consumer];
    }
    
}


- (void)dealloc {
    [self finishProducingWithError:nil];
}





#pragma mark Describing Producer


- (NSString *)descriptionName {
    return @"Producer";
}


- (NSString *)description {
    NSString *adjective = (self.isFinished? @"Finished " : @"");
    NSString *className = [[self.valueClass description] stringByAppendingString:@"s"] ?: @"something";
    return [NSString stringWithFormat:@"%@%@ of %@", adjective, self.shortDescription, className];
    // Finished Producer of NSStrings
    // Producer of something
}


- (NSDictionary *)debugDescriptionValues {
    return @{
             @"valueClass": self.valueClass ?: @"nil",
             @"lastValue": self.lastValue ?: @"nil",
             @"finished": (self.isFinished? @"YES" : @"NO"),
             @"error": self.error ?: @"nil",
             @"consumers": @(self.consumers.count),
             };
}





@end










@implementation OCAProducer (Chaining)




- (void)connectTo:(id<OCAConsumer>)consumer {
    [self addConsumer:consumer];
}


- (void)connectWeaklyTo:(id<OCAConsumer>)consumer {
    OCAPlaceholderObject *placeholder = [OCAPlaceholderObject placeholderForClass:[consumer consumedValueClass]];
    OCAInvoker *invoker = OCAInvocation(consumer, consumeValue:placeholder);
    [self addConsumer:invoker];
}


- (void)connectToMany:(id<OCAConsumer>)firstConsumer, ... NS_REQUIRES_NIL_TERMINATION {
    NSArray *consumers = OCAArrayFromVariadicArguments(firstConsumer);
    for (id<OCAConsumer> consumer in consumers) {
        [self addConsumer:consumer];
    }
}


- (OCAMediator *)chainTo:(OCAMediator *)mediator {
    [self addConsumer:mediator];
    return mediator;
}





- (OCAHub *)mergeWith:(OCAProducer *)producer, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray *producers = OCAArrayFromVariadicArguments(producer);
    [producers insertObject:self atIndex:0];
    return [[OCAHub alloc] initWithType:OCAHubTypeMerge producers:producers];
}


- (OCAHub *)combineWith:(OCAProducer *)producer, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray *producers = OCAArrayFromVariadicArguments(producer);
    [producers insertObject:self atIndex:0];
    return [[OCAHub alloc] initWithType:OCAHubTypeCombine producers:producers];
}


- (OCAHub *)dependOn:(OCAProducer *)producer, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray *producers = OCAArrayFromVariadicArguments(producer);
    [producers insertObject:self atIndex:0];
    return [[OCAHub alloc] initWithType:OCAHubTypeDependency producers:producers];
}





- (OCABridge *)transformValues:(NSValueTransformer *)firstTransformer, ... NS_REQUIRES_NIL_TERMINATION {
    NSArray *transformersArray = OCAArrayFromVariadicArguments(firstTransformer);
    NSValueTransformer *transformer = (transformersArray.count <= 1
                                       ? transformersArray.firstObject
                                       : [OCATransformer sequence:transformersArray]);
    OCABridge *bridge = [[OCABridge alloc] initWithTransformer:transformer];
    [self addConsumer:bridge];
    return bridge;
}


- (OCABridge *)replaceValuesWith:(id)replacement {
    OCABridge *bridge = [[OCABridge alloc] initWithTransformer:[OCATransformer replaceWith:replacement]];
    [self addConsumer:bridge];
    return bridge;
}


- (OCABridge *)replaceNilWith:(id)replacement {
    OCABridge *bridge = [[OCABridge alloc] initWithTransformer:[OCATransformer replaceNil:replacement]];
    [self addConsumer:bridge];
    return bridge;
}


- (OCABridge *)negateBoolean {
    OCABridge *bridge = [[OCABridge alloc] initWithTransformer:[OCATransformer negateBoolean]];
    [self addConsumer:bridge];
    return bridge;
}





- (OCAContext *)produceInContext:(OCAContext *)context {
    [self addConsumer:context];
    return context;
}


- (OCAContext *)switchToQueue:(OCAQueue *)queue {
    OCAContext *context = [[OCAContext alloc] initWithDefinitionBlock:^(OCAContextExecutionBlock executionBlock) {
        [queue performBlockAndTryWait:executionBlock];
    }];
    [self addConsumer:context];
    return context;
}





- (OCAFilter *)filterValues:(NSPredicate *)predicate {
    OCAFilter *filter = [[OCAFilter alloc] initWithPredicate:predicate];
    [self addConsumer:filter];
    return filter;
}


- (OCAFilter *)skipNil {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *b) {
        return (object != nil);
    }];
    OCAFilter *filter = [[OCAFilter alloc] initWithPredicate:predicate];
    [self addConsumer:filter];
    return filter;
}


- (OCAFilter *)skipFirst:(NSUInteger)count {
    OCAFilter *filter = [OCAFilter filterThatSkipsFirst:count];
    [self addConsumer:filter];
    return filter;
}


- (OCAFilter *)skipEqual {
    OCAFilter *filter = [OCAFilter filterThatSkipsEqual];
    [self addConsumer:filter];
    return filter;
}





- (OCAThrottle *)throttle:(NSTimeInterval)interval {
    OCAThrottle *throttle = [[OCAThrottle alloc] initWithInterval:interval continuous:NO];
    [self addConsumer:throttle];
    return throttle;
}


- (OCAThrottle *)throttleContinuous:(NSTimeInterval)interval {
    OCAThrottle *throttle = [[OCAThrottle alloc] initWithInterval:interval continuous:YES];
    [self addConsumer:throttle];
    return throttle;
}





- (void)subscribe:(void(^)(void))handler {
    if ( ! handler) return;
    OCASubscriber *subscriber = [[OCASubscriber alloc] initWithValueClass:nil valueHandler:^(id value) {
        handler();
    } finishHandler:nil];
    [self addConsumer:subscriber];
}


- (void)subscribeForClass:(Class)class handler:(void(^)(id value))handler {
    if ( ! handler) return;
    OCASubscriber *subscriber = [[OCASubscriber alloc] initWithValueClass:class valueHandler:handler finishHandler:nil];
    [self addConsumer:subscriber];
}


- (void)subscribeForClass:(Class)class handler:(void(^)(id value))handler finish:(void(^)(NSError *error))finishHandler {
    OCASubscriber *subscriber = [[OCASubscriber alloc] initWithValueClass:class valueHandler:handler finishHandler:finishHandler];
    [self addConsumer:subscriber];
}





- (void)invoke:(OCAInvoker *)invoker {
    [self addConsumer:invoker];
}




- (void)switchIf:(NSPredicate *)predicate then:(id<OCAConsumer>)thenConsumer else:(id<OCAConsumer>)elseConsumer {
    OCASwitch *ifSwitch = [[OCASwitch alloc] initWithDictionary:@{
                                                                  predicate: thenConsumer ?: (id)[NSNull null],
                                                                  [predicate negate]: elseConsumer ?: (id)[NSNull null],
                                                                  }];
    [self addConsumer:ifSwitch];
}


- (void)switchYes:(id<OCAConsumer>)trueConsumer no:(id<OCAConsumer>)falseConsumer {
    OCASwitch *booleanSwitch = [[OCASwitch alloc] initWithDictionary:@{
                                                                       [OCAPredicate isTrue]: trueConsumer ?: (id)[NSNull null],
                                                                       [OCAPredicate isFalse]: falseConsumer ?: (id)[NSNull null],
                                                                  }];
    [self addConsumer:booleanSwitch];
}





@end


