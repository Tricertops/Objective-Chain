//
//  OCANotificator.h
//  Objective-Chain
//
//  Created by Martin Kiss on 8.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAProducer.h"





@interface OCANotificator : OCAProducer



#pragma mark Creating Notifier

- (instancetype)initWithCenter:(NSNotificationCenter *)center name:(NSString *)name sender:(id)sender;

@property (atomic, readonly, weak) NSNotificationCenter *notificationCenter;
@property (atomic, readonly, copy) NSString *notificationName;
@property (atomic, readonly, weak) id notificationSender;


#pragma mark Receiving Notifications

+ (instancetype)notify:(NSString *)name;
+ (instancetype)notify:(NSString *)name from:(id)sender;
+ (OCAProducer *)notify:(NSString *)name from:(id)sender transform:(NSValueTransformer *)transformer;
+ (OCAProducer *)mergedNotify:(NSString *)name from:(NSArray *)senders;


#pragma mark Notification Transformations

- (OCAProducer *)produceName CONVENIENCE;
- (OCAProducer *)produceSender CONVENIENCE;
- (OCAProducer *)produceUserInfo CONVENIENCE;
- (OCAProducer *)produceUserInfoForKey:(NSString *)key CONVENIENCE;


#pragma mark Posting Notifications

//TODO: Move to OCAConsumer class
+ (id<OCAConsumer>)postNotification:(NSString *)name;
+ (id<OCAConsumer>)postNotification:(NSString *)name sender:(NSObject *)object;
+ (id<OCAConsumer>)postNotification:(NSString *)name sender:(NSObject *)object userInfoKey:(id)key;



@end


