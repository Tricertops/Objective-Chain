//
//  OCANotificator.m
//  Objective-Chain
//
//  Created by Martin Kiss on 8.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCANotificator.h"
#import "OCAProducer+Subclass.h"
#import "OCABridge.h"
#import "OCAHub.h"
#import "OCATransformer.h"
#import "OCADecomposer.h"





@interface OCANotificationPoster : OCAObject < OCAConsumer >


- (instancetype)initWithName:(NSString *)name sender:(NSObject *)sender userInfoKey:(id)key;

@property (atomic, readonly, copy) NSString *name;
@property (atomic, readonly, weak) NSObject *sender;
@property (atomic, readonly, assign) BOOL usesValueAsSender;
@property (atomic, readonly, strong) id userInfoKey;


@end










@implementation OCANotificator





#pragma mark Creating Notificator


- (instancetype)initWithCenter:(NSNotificationCenter *)center name:(NSString *)name sender:(NSObject *)sender {
    self = [super initWithValueClass:[NSNotification class]];
    if (self) {
        OCAAssert(name.length > 0, @"Missing notification name.") return nil;
        center = center ?: [NSNotificationCenter defaultCenter];
        
        OCANotificator *existing = [OCANotificator existingNotificatorForCenter:center name:name sender:sender];
        if (existing) return existing;
        
        self->_notificationCenter = center;
        self->_notificationName = name;
        self->_notificationSender = sender;
        
        [self produceValue:[NSNotification notificationWithName:name object:sender]];
        
        [center addObserver:self selector:@selector(produceValue:) name:name object:sender];
    }
    return self;
}


+ (instancetype)existingNotificatorForCenter:(NSNotificationCenter *)center name:(NSString *)name sender:(NSObject *)sender {
    return [center.decomposer findOwnedObjectOfClass:self usingBlock:^BOOL(OCANotificator *ownedNotificator) {
        BOOL theSameName = [ownedNotificator.notificationName isEqualToString:name];
        BOOL theSameSender = ownedNotificator.notificationSender == sender;
        return (theSameName && theSameSender);
    }];
}


- (void)dealloc {
    [self.notificationCenter removeObserver:self];
}


- (void)willAddConsumer:(id<OCAConsumer>)consumer {
    if ( ! self.consumers.count) {
        OCAWeakify(self);
        __weak NSObject *sender = self.notificationSender;
        
        [self.notificationCenter.decomposer addOwnedObject:self cleanup:^(__unsafe_unretained id owner){
            OCAStrongify(self);
            [sender.decomposer removeOwnedObject:self];
        }];
        [sender.decomposer addOwnedObject:self cleanup:^(__unsafe_unretained id owner){
            OCAStrongify(self);
            [self.notificationCenter.decomposer removeOwnedObject:self];
        }];
    }
}


- (void)didRemoveConsumer:(id<OCAConsumer>)consumer {
    if ( ! self.consumers.count) {
        [self.notificationCenter.decomposer removeOwnedObject:self];
        
        NSObject *sender = self.notificationSender;
        [sender.decomposer removeOwnedObject:self];
    }
}





#pragma mark Describing Notificator


- (NSString *)descriptionName {
    return @"Notificator";
}


- (NSString *)description {
    NSString *d = [NSString stringWithFormat:@"%@ for %@", self.shortDescription, self.notificationName];
    id sender = self.notificationSender;
    if (sender) {
        d = [d stringByAppendingFormat:@" from %@", sender];
    }
    return d;
    // Notifier (0x0) for %@ from %@
}


- (NSDictionary *)debugDescriptionValues {
    return @{
             @"center": self.notificationCenter,
             @"name": self.notificationName,
             @"sender": self.notificationSender ?: @"nil",
             };
}





#pragma mark Receiving Notifications


+ (instancetype)notify:(NSString *)name {
    return [self notify:name from:nil];
}


+ (instancetype)notify:(NSString *)name from:(NSObject *)sender {
    return [[self alloc] initWithCenter:nil name:name sender:sender];
}


+ (OCAProducer *)notify:(NSString *)name from:(NSObject *)sender transform:(NSValueTransformer *)transformer {
    OCANotificator *notifier = [[self alloc] initWithCenter:nil name:name sender:sender];
    OCABridge *bridge = [[OCABridge alloc] initWithTransformer:transformer];
    [notifier addConsumer:bridge];
    return bridge;
}


+ (OCAProducer *)mergedNotify:(NSString *)name from:(NSArray *)senders {
    NSMutableArray *notifiers = [[NSMutableArray alloc] init];
    for (id sender in senders) {
        OCANotificator *notifier = [[self alloc] initWithCenter:nil name:name sender:sender];
        [notifiers addObject:notifier];
    }
    return [[OCAHub alloc] initWithType:OCAHubTypeMerge producers:notifiers];
}





#pragma mark Notification Transformations


- (OCAProducer *)produceName {
    OCATransformer *transformer = [OCATransformer access:OCAKeyPath(NSNotification, name, NSString)];
    OCABridge *bridge = [[OCABridge alloc] initWithTransformer:transformer];
    [self addConsumer:bridge];
    return bridge;
}


- (OCAProducer *)produceSender {
    OCATransformer *transformer = [OCATransformer access:OCAKeyPath(NSNotification, object, NSObject)];
    OCABridge *bridge = [[OCABridge alloc] initWithTransformer:transformer];
    [self addConsumer:bridge];
    return bridge;
}


- (OCAProducer *)produceUserInfo {
    OCATransformer *transformer = [OCATransformer access:OCAKeyPath(NSNotification, userInfo, NSDictionary)];
    OCABridge *bridge = [[OCABridge alloc] initWithTransformer:transformer];
    [self addConsumer:bridge];
    return bridge;
}


- (OCAProducer *)produceUserInfoForKey:(NSString *)key {
    OCATransformer *transformer = [OCATransformer sequence:@[
                                                             [OCATransformer access:OCAKeyPath(NSNotification, userInfo, NSDictionary)],
                                                             [OCATransformer access:OCAKeyPathUnsafe(key)],
                                                             ]];
    OCABridge *bridge = [[OCABridge alloc] initWithTransformer:transformer];
    [self addConsumer:bridge];
    return bridge;
}





#pragma mark Posting Notifications


+ (id<OCAConsumer>)postNotification:(NSString *)name {
    return [[OCANotificationPoster alloc] initWithName:name sender:nil userInfoKey:nil];
}


+ (id<OCAConsumer>)postNotification:(NSString *)name sender:(id)object {
    return [[OCANotificationPoster alloc] initWithName:name sender:object userInfoKey:nil];
}


+ (id<OCAConsumer>)postNotification:(NSString *)name sender:(id)object userInfoKey:(NSString *)key {
    return [[OCANotificationPoster alloc] initWithName:name sender:object userInfoKey:key];
}





@end










@implementation OCANotificationPoster





#pragma mark Creating Notification Poster


- (instancetype)init {
    return [self initWithName:nil sender:nil userInfoKey:nil];
}


- (instancetype)initWithName:(NSString *)name sender:(NSObject *)sender userInfoKey:(id)key {
    self = [super init];
    if (self) {
        OCAAssert(name.length > 0, @"Missing notification name.") return nil;
        
        self->_name = name;
        self->_sender = sender;
        self->_usesValueAsSender = (sender == nil);
        self->_userInfoKey = key;
    }
    return self;
}





#pragma mark Consuming Values


- (Class)consumedValueClass {
    return nil;
}


- (void)consumeValue:(id)value {
    NSObject *sender = (self.usesValueAsSender? value : self.sender);
    if ( ! sender) return;
    
    NSDictionary *userInfo = (self.userInfoKey && value? @{ self.userInfoKey: value } : nil);
    [[NSNotificationCenter defaultCenter] postNotificationName:self.name
                                                        object:sender
                                                      userInfo:userInfo];
}


- (void)finishConsumingWithError:(NSError *)error {
    // Nothing.
}





@end


