//
//  OCANotificator.m
//  Objective-Chain
//
//  Created by Martin Kiss on 8.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCANotificator.h"
#import "OCAProducer+Private.h"
#import "OCABridge.h"
#import "OCAHub.h"
#import "OCATransformer+Predefined.h"
#import "OCADecomposer.h"





@interface OCANotificationPoster : OCAObject < OCAConsumer >


- (instancetype)initWithName:(NSString *)name sender:(NSObject *)sender userInfoKey:(id)key;

@property (atomic, readonly, copy) NSString *name;
@property (atomic, readonly, weak) NSObject *sender;
@property (atomic, readonly, assign) BOOL usesValueAsSender;
@property (atomic, readonly, strong) id userInfoKey;


@end










@implementation OCANotificator





#pragma mark Creating Notifier


- (instancetype)initWithCenter:(NSNotificationCenter *)center name:(NSString *)name sender:(NSObject *)sender {
    self = [super initWithValueClass:[NSNotification class]];
    if (self) {
        OCAAssert(name.length > 0, @"Missing notification name.");
        
        center = center ?: [NSNotificationCenter defaultCenter];
        
        self->_notificationCenter = center;
        self->_notificationName = name;
        self->_notificationSender = sender;
        
        [center addObserver:self selector:@selector(produceValue:) name:name object:sender];
        
        OCAWeakify(self);
        OCAWeakify(center);
        OCAWeakify(sender);
        
        [center.decomposer addOwnedObject:self cleanup:^{
            OCAStrongify(self);
            OCAStrongify(sender);
            [sender.decomposer removeOwnedObject:self];
        }];
        [sender.decomposer addOwnedObject:self cleanup:^{
            OCAStrongify(self);
            OCAStrongify(center);
            [center.decomposer removeOwnedObject:self];
            [center removeObserver:self];
        }];
    }
    return self;
}


- (void)dealloc {
    [self.notificationCenter removeObserver:self];
}





#pragma mark Describing Notifier


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
             @"sender": self.notificationSender,
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
    return [notifier bridgeWithFilter:nil transform:transformer];
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


+ (NSValueTransformer *)notificationName {
    return [OCATransformer access:OCAKeyPath(NSNotification, name, NSString)];
}


+ (NSValueTransformer *)notificationSender {
    return [OCATransformer access:OCAKeyPath(NSNotification, object, NSString)];
}


+ (NSValueTransformer *)notificationUserInfo {
    return [OCATransformer access:OCAKeyPath(NSNotification, userInfo, NSDictionary)];
}


+ (NSValueTransformer *)notificationUserInfoKey:(NSString *)key {
    return [OCATransformer sequence:@[
                                      [OCATransformer access:OCAKeyPath(NSNotification, userInfo, NSDictionary)],
                                      [OCATransformer access:OCAKeyPathUnsafe(key)],
                                      ]];
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


